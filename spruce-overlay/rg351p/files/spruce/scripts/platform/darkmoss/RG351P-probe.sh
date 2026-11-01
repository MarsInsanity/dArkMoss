#!/bin/sh
# Overlay only (not part of the spruceOS change): what the RG351P's input
# stack looks like, for bring-up. Run once per boot from RG351P.cfg, in the
# background so it can wait for the USB pad. Writes
# /mnt/SDCARD/Saves/spruce/rg351p-input.txt.

OUT="${RG351P_PROBE_OUT:-/mnt/SDCARD/Saves/spruce/rg351p-input.txt}"
PAD="OpenSimHardware OSH PB Controller"

# The pad enumerates on USB about 10 s into boot.
i=0
while [ $i -lt 30 ]; do
    grep -qs "$PAD" /sys/class/input/event*/device/name && break
    sleep 1; i=$((i + 1))
done

{
    echo "==== $(date) (waited ${i}s for the pad)"
    echo "--- os-release"
    grep -E '^(OS_VERSION|SPRUCE_PLATFORM)=' /etc/os-release
    echo "--- dArkMoss joypad rule"
    ls -l /etc/udev/rules.d/ 2>&1
    cat /etc/udev/rules.d/70-rg351p-joypad.rules 2>&1
    echo "--- /proc/bus/input/devices"
    cat /proc/bus/input/devices
    echo "--- /dev/input"
    ls -l /dev/input /dev/input/by-id /dev/input/by-path 2>&1
    for dir in /sys/class/input/event* /sys/class/input/js*; do
        [ -e "$dir" ] || continue
        [ "$(cat "$dir/device/name" 2>/dev/null)" = "$PAD" ] || continue
        node="/dev/input/${dir##*/}"
        echo "--- udev properties of $node"
        udevadm info --query=property --name="$node" 2>&1
    done
    echo "--- processes holding the pad"
    for dir in /sys/class/input/event*; do
        [ "$(cat "$dir/device/name" 2>/dev/null)" = "$PAD" ] || continue
        node="/dev/input/${dir##*/}"
        for fd in /proc/[0-9]*/fd/*; do
            [ "$(readlink "$fd" 2>/dev/null)" = "$node" ] || continue
            pid="${fd#/proc/}"; pid="${pid%%/*}"
            echo "  $node: pid $pid $(tr '\0' ' ' < /proc/$pid/cmdline 2>/dev/null | cut -c1-160)"
        done
    done
} >> "$OUT" 2>&1
