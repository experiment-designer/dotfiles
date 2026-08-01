#!/bin/bash
# Bluetooth Media Toggle - switch between BT headset and speakers

set -o pipefail

# Device config - each MAC is tried in turn, first one that answers wins.
# Two identical EarFun Air Pro 4 sets: each has its own MAC, list both.
BT_MACS=(
    70:5A:6F:6B:5C:35   # set #1
    70:5A:6F:6B:62:21   # set #2
)

SPEAKERS="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"
LAPTOP_MIC="alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source"

SCAN_TIMEOUT=12

# Point the BT_* vars at one device
use_mac() {
    BT_MAC="$1"
    local u="${1//:/_}"   # PipeWire node names use underscores, not colons
    BT_CARD="bluez_card.$u"
    BT_SINK_PREFIX="bluez_output.$u"
    BT_SOURCE_PREFIX="bluez_input.$u"
}
use_mac "${BT_MACS[0]}"

# --- Bluetoothctl wrapper ---
# Non-interactive bluetoothctl returns empty on some systems because it
# doesn't wait long enough to connect to bluetoothd. Pipe commands instead.
btcmd() { echo -e "$1\nquit" | bluetoothctl 2>/dev/null; }

# --- Preflight ---

require_adapter() {
    rfkill unblock bluetooth 2>/dev/null   # clears a soft block, no-op otherwise
    compgen -G "/sys/class/bluetooth/*" >/dev/null && return 0

    echo "Error: no Bluetooth controller present."
    rfkill list bluetooth 2>/dev/null | grep -q "Hard blocked: yes" &&
        echo "  Hard-blocked - check the ThinkPad wireless switch / BIOS."
    [[ -d "/lib/modules/$(uname -r)" ]] ||
        echo "  Running kernel $(uname -r) has no modules installed (kernel was upgraded) - reboot."
    return 1
}

# --- State checks ---

current_sink() { pactl get-default-sink 2>/dev/null; }
on_bluetooth() { [[ "$(current_sink)" == *bluez* ]]; }
on_speakers() { [[ "$(current_sink)" == "$SPEAKERS" ]]; }
# NB: these all use $(...) + [[ == ]] rather than `| grep -q`. grep -q exits on
# first match, the writer gets SIGPIPE, and pipefail then reports the whole
# pipeline as failed - turning a match into a false negative, intermittently.
has_bt_card() { [[ "$(pactl list cards short 2>/dev/null)" == *"$BT_CARD"* ]]; }

# Resolve the real node names - PipeWire appends a profile index (e.g. ".1")
bt_sink() { pactl list sinks short 2>/dev/null | awk -v p="$BT_SINK_PREFIX" 'index($2,p)==1 {print $2; exit}'; }
bt_source() { pactl list sources short 2>/dev/null | awk -v p="$BT_SOURCE_PREFIX" 'index($2,p)==1 {print $2; exit}'; }

bt_info() { btcmd "info $BT_MAC"; }
bt_connected() { [[ "$(bt_info)" == *"Connected: yes"* ]]; }
bt_paired() { [[ "$(bt_info)" == *"Paired: yes"* ]]; }
bt_trusted() { [[ "$(bt_info)" == *"Trusted: yes"* ]]; }
bt_known() { [[ "$(btcmd devices)" == *"$BT_MAC"* ]]; }

# --- Bluetooth connection ---

bt_scan_and_find() {
    echo "Scanning for $BT_MAC..."

    # Watch bluetoothctl output stream for [NEW] Device with our MAC
    # (polling 'devices' in separate sessions doesn't work reliably)
    if expect -c "
        log_user 0
        set timeout $SCAN_TIMEOUT
        spawn bluetoothctl
        expect -re \".+\"
        send \"scan on\r\"
        expect {
            \"$BT_MAC\" {
                send \"scan off\r\"
                expect -re \".+\"
                send \"quit\r\"
                expect eof
                exit 0
            }
            timeout {
                send \"scan off\r\"
                expect -re \".+\"
                send \"quit\r\"
                expect eof
                exit 1
            }
        }
    " &>/dev/null; then
        echo "Found!"
        return 0
    fi
    return 1
}

bt_pair_interactive() {
    echo "Pairing..."
    local out
    out="$(expect -c "
        set timeout 30
        spawn bluetoothctl
        expect -re \".+\"
        send \"agent on\r\"
        expect -re \".+\"
        send \"default-agent\r\"
        expect -re \".+\"
        send \"pair $BT_MAC\r\"
        expect {
            \"Pairing successful\" { }
            \"Already Exists\" { }
            \"Authorize service\" {
                send \"yes\r\"
                exp_continue
            }
            timeout { exit 1 }
        }
        send \"trust $BT_MAC\r\"
        expect -re \".+\"
        send \"quit\r\"
        expect eof
    " 2>&1)"
    [[ "$out" == *"Pairing successful"* || "$out" == *"already exists"* ]]
}

bt_connect_simple() {
    # Simple connect - works when device is trusted
    expect -c "
        log_user 1
        set timeout 15
        spawn bluetoothctl
        expect -re \".+\"
        send \"connect $BT_MAC\r\"
        expect {
            \"Connection successful\" { send \"quit\r\"; expect eof; exit 0 }
            \"AuthenticationFailed\" { send \"quit\r\"; expect eof; exit 2 }
            \"key-missing\" { send \"quit\r\"; expect eof; exit 2 }
            \"not available\" { send \"quit\r\"; expect eof; exit 1 }
            timeout { send \"quit\r\"; expect eof; exit 1 }
        }
    " &>/dev/null
    local ret=$?
    if [[ $ret -eq 0 ]]; then return 0
    elif [[ $ret -eq 2 ]]; then return 2
    fi
    return 1
}

bt_trust() {
    btcmd "trust $BT_MAC" &>/dev/null
}

bt_remove() {
    btcmd "remove $BT_MAC" &>/dev/null
    sleep 0.5
}

ensure_connected() {
    # Already connected?
    if bt_connected; then
        return 0
    fi

    echo "Connecting to $BT_MAC..."

    # Trust device if paired but not trusted (prevents auth prompts)
    if bt_paired && ! bt_trusted; then
        bt_trust
    fi

    # Try simple connect first if device is known and paired
    if bt_paired; then
        local ret
        bt_connect_simple
        ret=$?
        if [[ $ret -eq 0 ]]; then
            echo "Connected!"
            return 0
        elif [[ $ret -eq 2 ]]; then
            # If key-missing, remove and re-pair
            echo "Pairing keys out of sync, resetting..."
            bt_remove
        fi
    fi

    # Scan if device not known
    if ! bt_known; then
        if ! bt_scan_and_find; then
            echo "Error: device not found."
            echo "Put the headset in pairing mode (hold the case button until the LED flashes)"
            return 1
        fi
    fi

    # Pair if needed
    if ! bt_paired; then
        if ! bt_pair_interactive; then
            echo "Error: Pairing failed"
            return 1
        fi
        bt_trust
        echo "Paired!"
    fi

    # Connect
    if ! bt_connect_simple; then
        echo "Connection failed, trying full reset..."
        bt_remove

        if ! bt_scan_and_find; then
            echo "Error: Device not found after reset"
            return 1
        fi

        if ! bt_pair_interactive; then
            echo "Error: Re-pairing failed"
            return 1
        fi
        bt_trust

        if ! bt_connect_simple; then
            echo "Error: Connection failed after reset"
            return 1
        fi
    fi

    echo "Connected!"
    return 0
}

# One scan, print whichever of BT_MACS are actually in range
scan_visible() {
    local out m
    out=$(timeout $((SCAN_TIMEOUT + 5)) bluetoothctl --timeout "$SCAN_TIMEOUT" scan on 2>/dev/null)
    for m in "${BT_MACS[@]}"; do
        grep -qi "$m" <<<"$out" && echo "$m"
    done
}

# Try every known MAC, leaving BT_* pointed at whichever one answered.
# Cheap connect pass first, then the full pair/reset path - but only on a
# device that's in range, so an out-of-range set doesn't get its pairing
# wiped by ensure_connected's reset branch.
connect_any() {
    local m visible
    for m in "${BT_MACS[@]}"; do
        use_mac "$m"
        bt_connected && return 0
    done

    for m in "${BT_MACS[@]}"; do
        use_mac "$m"
        bt_paired || continue
        echo "Trying $m..."
        bt_connect_simple && { echo "Connected to $m"; return 0; }
    done

    echo "Scanning..."
    visible=$(scan_visible)
    if [[ -z "$visible" ]]; then
        echo "Error: no known headset in range."
        echo "Put it in pairing mode (hold the case button until the LED flashes)"
        return 1
    fi
    while read -r m; do
        use_mac "$m"
        ensure_connected && return 0
    done <<<"$visible"
    return 1
}

find_active_card() {
    local m
    for m in "${BT_MACS[@]}"; do
        use_mac "$m"
        has_bt_card && return 0
    done
    return 1
}

wait_for_audio_card() {
    echo "Waiting for audio card..."
    for ((i=0; i<20; i++)); do
        sleep 0.5
        if has_bt_card; then
            return 0
        fi
    done
    return 1
}

# Reconnect to fix half-connected state
bt_reconnect() {
    echo "Reconnecting..."
    btcmd "disconnect $BT_MAC" &>/dev/null
    sleep 1
    bt_connect_simple
}

# --- Audio switching ---

switch_to_speakers() {
    pactl set-default-sink "$SPEAKERS" 2>/dev/null
    pactl set-default-source "$LAPTOP_MIC" 2>/dev/null
    move_streams "$SPEAKERS"
    echo "Switched to Speakers"
}

switch_to_bluetooth() {
    local want="$1" sink source

    # Just try the profile; pactl fails if it isn't available
    if [[ "$want" == "hfp" ]]; then
        pactl set-card-profile "$BT_CARD" headset-head-unit 2>/dev/null ||
            { echo "Error: HFP profile not available"; return 1; }
    else
        pactl set-card-profile "$BT_CARD" a2dp-sink 2>/dev/null ||
            pactl set-card-profile "$BT_CARD" headset-head-unit 2>/dev/null ||
            { echo "Error: No audio profile available"; return 1; }
    fi
    sleep 0.5

    sink=$(bt_sink)
    [[ -n "$sink" ]] || { echo "Error: Bluetooth sink not available"; return 1; }
    pactl set-default-sink "$sink" 2>/dev/null

    source=$(bt_source)
    if [[ "$want" == "hfp" && -n "$source" ]]; then
        pactl set-default-source "$source" 2>/dev/null
    else
        pactl set-default-source "$LAPTOP_MIC" 2>/dev/null
    fi

    move_streams "$sink"
    echo "Switched to $BT_MAC ($want)"
}

move_streams() {
    local target="$1"
    pactl list sink-inputs short 2>/dev/null | while read -r id _; do
        pactl move-sink-input "$id" "$target" 2>/dev/null
    done
}

# --- Status ---

show_status() {
    echo "Audio:"
    echo "  Current sink: $(current_sink)"
    echo "  On speakers: $(on_speakers && echo yes || echo no)"
    echo "  On bluetooth: $(on_bluetooth && echo yes || echo no)"
    echo ""
    echo "Adapter: $(compgen -G '/sys/class/bluetooth/*' >/dev/null && echo present || echo MISSING)"
    echo ""
    local m
    for m in "${BT_MACS[@]}"; do
        use_mac "$m"
        echo "$m:"
        echo "  Known: $(bt_known && echo yes || echo no)"
        echo "  Paired: $(bt_paired && echo yes || echo no)"
        echo "  Connected: $(bt_connected && echo yes || echo no)"
        echo "  Audio card: $(has_bt_card && echo yes || echo no)"
    done
}

# --- Main ---

case "$1" in
    --status|-s)
        show_status
        exit 0
        ;;
    --help|-h)
        echo "Usage: $0 [--hfp] [--status]"
        echo "  --hfp     Use HFP profile (with mic, lower quality)"
        echo "  --status  Show current state"
        echo "  (no args) Toggle between speakers and headset (A2DP)"
        exit 0
        ;;
esac

# Check for expect
if ! command -v expect &>/dev/null; then
    echo "Error: 'expect' is required. Install with: sudo pacman -S expect"
    exit 1
fi

# Toggle logic
if on_bluetooth; then
    switch_to_speakers
else
    require_adapter || exit 1

    # Need bluetooth connection
    if ! find_active_card; then
        if ! connect_any; then
            exit 1
        fi
        if ! wait_for_audio_card; then
            # Audio card didn't appear - try reconnecting to fix half-connected state
            if bt_connected; then
                bt_reconnect
                if ! wait_for_audio_card; then
                    echo "Error: Audio card not available"
                    exit 1
                fi
            else
                echo "Error: Audio card not available"
                exit 1
            fi
        fi
    fi

    if [[ "$1" == "--hfp" ]]; then
        switch_to_bluetooth hfp
    else
        switch_to_bluetooth a2dp
    fi
fi
