# Loaded via `geninclude host.py` in kitty.conf.
# Prints hosts/<short-hostname>.conf (if present) so each machine can
# override settings from the shared kitty.conf. Hosts without a file
# just get the defaults.
import os
import socket

host = socket.gethostname().split(".")[0]
path = os.path.expanduser(f"~/.config/kitty/hosts/{host}.conf")
if os.path.isfile(path):
    with open(path) as f:
        print(f.read())
