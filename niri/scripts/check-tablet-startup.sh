#!/usr/bin/env bash
# Check if device is in tablet mode on startup; if so, start on-screen keyboard.
python3 -c '
import glob, fcntl, array, sys
EVIOCGSW = 0x8040451b
for path in glob.glob("/sys/class/input/input*/capabilities/sw"):
    try:
        with open(path) as f:
            val = int(f.read().strip(), 16)
        if (val >> 1) & 1:
            dev_dir = path.rsplit("/", 2)[0]
            for ev in glob.glob(f"{dev_dir}/event*"):
                ev_name = ev.split("/")[-1]
                with open(f"/dev/input/{ev_name}", "rb") as ev_f:
                    buf = array.array("B", [0]*8)
                    fcntl.ioctl(ev_f, EVIOCGSW, buf, True)
                    if (buf[0] >> 1) & 1:
                        sys.exit(0)
    except Exception:
        continue
sys.exit(1)
' && wvkbd-service tablet-on || true
