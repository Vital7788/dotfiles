#!/bin/sh

# https://github.com/swaywm/sway/wiki/systemd-integration
# https://wiki.archlinux.org/title/XDG_Desktop_Portal#Portal_does_not_start
systemctl --user import-environment \
	WAYLAND_DISPLAY \
	XDG_CURRENT_DESKTOP \
	XDG_SESSION_TYPE

exec systemctl --user start mango-session.target
