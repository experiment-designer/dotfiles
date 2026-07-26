#!/bin/bash
# Bluetooth Media Toggle - switch between EarFun and speakers

set -o pipefail

# Device config
BT_MAC="70:5A:6F:6B:5C:35"
BT_CARD="bluez_card.70_5A_6F_6B_5C_35"
BT_SINK="bluez_output.${BT_MAC}"
BT_SOURCE="bluez_input.${BT_MAC}"
SPEAKERS="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"
LAPTOP_MIC="alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source"

SCAN_TIMEOUT=12

# --- Bluetoothctl wrapper ---
# Non-interactive bluetoothctl returns empty on some systems because it
# doesn't wait long enough to connect to bluetoothd. Pipe commands instead.
btcmd() { echo -e "$1\nquit" | bluetoothctl 2>/dev/null; }

# --- State checks ---

current_sink() { pactl get-default-sink 2>/dev/null; }
on_bluetooth() { [[ "$(current_sink)" == *bluez* ]]; }
on_speakers() { [[ "$(current_sink)" == "$SPEAKERS" ]]; }
has_bt_card() { pactl list cards short 2>/dev/null | grep -q "$BT_CARD"; }

bt_info() { btcmd "info $BT_MAC"; }
bt_connected() { bt_info | grep -q "Connected: yes"; }
bt_paired() { bt_info | grep -q "Paired: yes"; }
bt_trusted() { bt_info | grep -q "Trusted: yes"; }
bt_known() { btcmd "devices" | grep -q "$BT_MAC"; }

# --- Bluetooth connection ---

# Run bluetoothctl commands with agent in an interactive session
btctl() {
    # Use expect-like input to handle prompts, auto-answer yes to authorize
    bluetoothctl <<EOF
agent on
default-agent
$@
EOF
}

bt_scan_and_find() {
    echo "Scanning for EarFun..."

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
    expect -c "
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
    " 2>&1 | grep -qE "Pairing successful|already exists"
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

    echo "Connecting to EarFun..."

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
            echo "Error: EarFun not found."
            echo "Put earbuds in pairing mode (hold case button until LED flashes)"
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

get_available_profile() {
    # Return best available profile (prefer A2DP for quality)
    # PipeWire uses a2dp-sink / headset-head-unit profile names
    local cards
    cards=$(pactl list cards 2>/dev/null)
    if echo "$cards" | grep -q "a2dp-sink:.*available"; then
        echo "a2dp"
    elif echo "$cards" | grep -q "headset-head-unit:.*available"; then
        echo "hfp"
    else
        echo "none"
    fi
}

switch_to_bluetooth() {
    local requested="$1"
    local available profile

    available=$(get_available_profile)

    if [[ "$available" == "none" ]]; then
        echo "Error: No audio profile available"
        return 1
    fi

    # Use requested if available, otherwise use what's available
    if [[ "$requested" == "hfp" && "$available" != "none" ]]; then
        profile="hfp"
    elif [[ "$available" == "a2dp" ]]; then
        profile="a2dp"
    else
        profile="hfp"
    fi

    if [[ "$profile" == "hfp" ]]; then
        pactl set-card-profile "$BT_CARD" headset-head-unit 2>/dev/null
        sleep 0.5
        pactl set-default-sink "$BT_SINK" 2>/dev/null
        pactl set-default-source "$BT_SOURCE" 2>/dev/null
    else
        pactl set-card-profile "$BT_CARD" a2dp-sink 2>/dev/null
        sleep 0.5
        pactl set-default-sink "$BT_SINK" 2>/dev/null
        pactl set-default-source "$LAPTOP_MIC" 2>/dev/null
    fi

    # Verify sink exists
    if ! pactl list sinks short 2>/dev/null | grep -q "$BT_SINK"; then
        echo "Error: Sink $BT_SINK not available"
        return 1
    fi

    move_streams "$BT_SINK"

    if [[ "$profile" == "hfp" ]]; then
        echo "Switched to EarFun (HFP - with mic)"
    else
        echo "Switched to EarFun (A2DP)"
    fi
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
    echo "  BT card available: $(has_bt_card && echo yes || echo no)"
    echo ""
    echo "Bluetooth:"
    echo "  Device known: $(bt_known && echo yes || echo no)"
    echo "  Paired: $(bt_paired && echo yes || echo no)"
    echo "  Connected: $(bt_connected && echo yes || echo no)"
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
        echo "  (no args) Toggle between speakers and EarFun (A2DP)"
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
    # Need bluetooth connection
    if ! has_bt_card; then
        if ! ensure_connected; then
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
