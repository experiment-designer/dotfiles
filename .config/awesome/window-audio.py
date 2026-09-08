#!/usr/bin/env python3
"""Toggle existing playback streams belonging to an Awesome client."""

import argparse
import json
from pathlib import Path
import subprocess
import sys


def number(value):
    try:
        return int(str(value), 16 if str(value).startswith("0x") else 10)
    except (TypeError, ValueError):
        return 0


def belongs_to(pid, owner):
    """Include child audio processes, but never walk up to sibling apps."""
    seen = set()
    while pid > 1 and pid not in seen:
        if pid == owner:
            return True
        seen.add(pid)
        try:
            pid = int(Path(f"/proc/{pid}/stat").read_text().rsplit(")", 1)[1].split()[1])
        except (OSError, ValueError, IndexError):
            break
    return False


def select_streams(streams, xid, pid, title):
    exact = [s for s in streams
             if number(s.get("properties", {}).get("window.x11.xid")) == xid and xid]
    if exact:
        return exact, "window"
    candidates = [s for s in streams
                  if not number(s.get("properties", {}).get("window.x11.xid"))
                  and belongs_to(number(s.get("properties", {}).get("application.process.id")), pid)]
    # Browsers often publish the tab title instead of an X11 window ID.
    titled = []
    for stream in candidates:
        props = stream.get("properties", {})
        for key in ("window.name", "media.name"):
            name = props.get(key, "").strip()
            if name and (title == name or any(title.startswith(name + sep)
                                             for sep in (" — ", " - ", " – "))):
                titled.append(stream)
                break
    return (titled, "window title") if titled else (candidates, "application; may include other windows")


def pactl(*args):
    return subprocess.run(["pactl", *args], check=True, text=True,
                          capture_output=True, timeout=5).stdout


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("xid", type=int)
    parser.add_argument("pid", type=int)
    parser.add_argument("title")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    streams, scope = select_streams(json.loads(pactl("-f", "json", "list", "sink-inputs")),
                                    args.xid, args.pid, args.title)
    if not streams:
        print("No playback streams found for this window. Start audio first.")
        return
    mute = not all(s.get("mute", False) for s in streams)
    if not args.dry_run:
        for stream in streams:
            pactl("set-sink-input-mute", str(stream["index"]), "1" if mute else "0")
    names = list(dict.fromkeys(s.get("properties", {}).get("media.name", "Audio") for s in streams))
    action = "Would mute" if args.dry_run and mute else "Would unmute" if args.dry_run else "Muted" if mute else "Unmuted"
    print(f"{action}: {', '.join(names)}\nScope: {scope}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, subprocess.SubprocessError, ValueError) as exc:
        detail = exc.stderr.strip() if isinstance(exc, subprocess.CalledProcessError) else str(exc)
        print(f"Could not toggle window audio: {detail}", file=sys.stderr)
        sys.exit(1)
