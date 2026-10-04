#!/usr/bin/env python3
"""Exercise the actual startup loop without connecting to an X server."""
from pathlib import Path
import os
import re
import subprocess
import tempfile

source = (Path(__file__).resolve().parents[1] / ".xinitrc").read_text()
match = re.search(r"(?ms)^\(\n.*?^\) &(?=\nxset dpms)", source)
assert match, "screensaver loop missing"
loop = match.group().removesuffix(" &")
fakes = r'''
xset() {
    printf '%s\n' "$*" >> calls
    case "$*" in
        q)
            [ "$(cat phase)" -lt 5 ] || return 1
            read -r timeout cycle < settings
            printf 'Screen Saver:\n  prefer blanking: yes\n  timeout: %s    cycle: %s\nDPMS:\n  Standby: 0\n' "$timeout" "$cycle"
            ;;
        "s 3600 0") printf '3600 0\n' > settings ;;
        *) return 64 ;;
    esac
}
sleep() {
    [ "$*" = 300 ] || exit 65
    phase=$(cat phase)
    phase=$((phase + 1))
    printf '%s\n' "$phase" > phase
    case "$phase" in
        3) printf '3600 30\n' > settings ;;
        4) printf '0 0\n' > settings ;;
    esac
}
'''

with tempfile.TemporaryDirectory(prefix="idle-timeout-test-") as directory:
    root = Path(directory)
    (root / "phase").write_text("0\n")
    (root / "settings").write_text("2700 0\n")
    env = {key: value for key, value in os.environ.items() if key != "DISPLAY"}
    subprocess.run(["sh", "-c", fakes + loop], cwd=root, env=env,
                   check=True, timeout=5, capture_output=True, text=True)
    assert (root / "calls").read_text().splitlines() == [
        "q", "s 3600 0", "q", "q", "q", "s 3600 0",
        "q", "s 3600 0", "q",
    ], "changed settings must be repaired; unchanged settings must not rearm"
    assert (root / "phase").read_text() == "5\n", "connection loss must exit"
print("PASS: repairs timeout/cycle changes, preserves unchanged timers, exits on disconnect")
