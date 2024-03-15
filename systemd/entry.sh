mkdir -p /run/dbus
dbus-daemon --system

# Remove a file that might be left from previous runs and would block systemd
rm -f /run/nologin

# Start systemd
exec /sbin/init