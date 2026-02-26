#!/bin/bash
# Bluetooth Media Toggle - switch between EarFun and speakers

set -o pipefail

# Device config
BT_MAC="70:5A:6F:6B:5C:35"
BT_CARD="bluez_card.70_5A_6F_6B_5C_35"
BT_SINK_A2DP="bluez_sink.70_5A_6F_6B_5C_35.a2dp_sink"
BT_SINK_HFP="bluez_sink.70_5A_6F_6B_5C_35.handsfree_head_unit"
BT_SOURCE_HFP="bluez_source.70_5A_6F_6B_5C_35.handsfree_head_unit"
SPEAKERS="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"
LAPTOP_MIC="alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source"

SCAN_TIMEOUT=12

# --- State checks ---

current_sink() { pactl get-default-sink 2>/dev/null; }
on_bluetooth() { [[ "$(current_sink)" == *bluez* ]]; }
on_speakers() { [[ "$(current_sink)" == "$SPEAKERS" ]]; }
has_bt_card() { pactl list cards short 2>/dev/null | grep -q "$BT_CARD"; }

bt_info() { bluetoothctl info "$BT_MAC" 2>/dev/null; }
bt_connected() { bt_info | grep -q "Connected: yes"; }
bt_paired() { bt_info | grep -q "Paired: yes"; }
bt_trusted() { bt_info | grep -q "Trusted: yes"; }
bt_known() { bluetoothctl devices 2>/dev/null | grep -q "$BT_MAC"; }

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

    # Run scan with timeout
    timeout "$SCAN_TIMEOUT" bluetoothctl --timeout "$SCAN_TIMEOUT" scan on &>/dev/null &
    local scan_pid=$!

    # Poll for device appearance
    for ((i=0; i<SCAN_TIMEOUT*2; i++)); do
        if bluetoothctl devices 2>/dev/null | grep -q "$BT_MAC"; then
            kill $scan_pid 2>/dev/null
            echo "Found!"
            return 0
        fi
        sleep 0.5
    done

    kill $scan_pid 2>/dev/null
    return 1
}

bt_pair_interactive() {
    echo "Pairing..."
    # Use expect to handle authorization prompts
    expect -c "
        set timeout 30
        spawn bluetoothctl
        expect \"#\"
        send \"agent on\r\"
        expect \"#\"
        send \"default-agent\r\"
        expect \"#\"
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
        expect \"#\"
        send \"quit\r\"
        expect eof
    " 2>&1 | grep -qE "Pairing successful|already exists"
}

bt_connect_simple() {
    # Simple connect - works when device is trusted
    local out
    out=$(timeout 10 bluetoothctl connect "$BT_MAC" 2>&1)
    if echo "$out" | grep -q "Connection successful"; then
        return 0
    elif echo "$out" | grep -q "org.bluez.Error.AuthenticationFailed\|key-missing"; then
        return 2  # needs re-pairing
    fi
    return 1
}

bt_trust() {
    bluetoothctl trust "$BT_MAC" &>/dev/null
}

bt_remove() {
    bluetoothctl remove "$BT_MAC" &>/dev/null
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
    bluetoothctl disconnect "$BT_MAC" &>/dev/null
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
    local cards
    cards=$(pactl list cards 2>/dev/null)
    if echo "$cards" | grep -q "a2dp_sink.*available: yes"; then
        echo "a2dp"
    elif echo "$cards" | grep -q "handsfree_head_unit.*available: yes"; then
        echo "hfp"
    else
        echo "none"
    fi
}

switch_to_bluetooth() {
    local requested="$1"
    local available profile sink source

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
        pactl set-card-profile "$BT_CARD" handsfree_head_unit 2>/dev/null
        sleep 0.5
        sink="$BT_SINK_HFP"
        source="$BT_SOURCE_HFP"
    else
        pactl set-card-profile "$BT_CARD" a2dp_sink 2>/dev/null
        sleep 0.5
        sink="$BT_SINK_A2DP"
        source="$LAPTOP_MIC"
    fi

    # Verify sink exists
    if ! pactl list sinks short 2>/dev/null | grep -q "$sink"; then
        echo "Error: Sink $sink not available"
        return 1
    fi

    pactl set-default-sink "$sink" 2>/dev/null
    pactl set-default-source "$source" 2>/dev/null
    move_streams "$sink"

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
