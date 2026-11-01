#!/bin/sh
# Adds the RG351P to spruce's shared files, in place, next to the V10's lines.
#
# Run (not sourced) from RG351P.cfg on every boot. It edits whatever spruce
# is on the card instead of replacing whole files with copies from one spruce
# revision, so it works across spruce versions, and puts the lines back after
# a spruce update overwrites the files. Every edit is skipped when its file
# already names the RG351P, and a file whose V10 anchor is missing is left
# alone and logged, never half-edited.

SD="${RG351P_SPRUCE_ROOT:-/mnt/SDCARD}"
STAMP=/tmp/rg351p_patch_checked
LOCK=/tmp/rg351p_patch.lock
LOG="${RG351P_PATCH_LOG:-$SD/Saves/spruce/rg351p-patch.log}"

# make.sh applies this to a spruceOS checkout: no once-per-boot stamp there.
[ -n "$RG351P_SPRUCE_ROOT" ] && STAMP=/dev/null/none
[ -f "$STAMP" ] && exit 0
mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

log() {
    mkdir -p "$(dirname "$LOG")" 2>/dev/null
    echo "$(date '+%F %T') $*" >> "$LOG" 2>/dev/null
}

# patch FILE ANCHOR_REGEX SED_EXPRESSION
# FILE must contain ANCHOR_REGEX; the sed expression is then applied, and the
# result must name RG351P before it replaces the file.
patch() {
    _f="$SD/$1"
    [ -f "$_f" ] || { log "skip $1: not on the card"; return 0; }
    grep -q 'RG351P' "$_f" && return 0
    if ! grep -q "$2" "$_f"; then
        log "skip $1: V10 line not found, RG351P not added"
        return 0
    fi
    sed "$3" "$_f" > "$_f.rg351p.tmp" 2>/dev/null
    if grep -q 'RG351P' "$_f.rg351p.tmp" 2>/dev/null; then
        chmod --reference="$_f" "$_f.rg351p.tmp" 2>/dev/null
        mv -f "$_f.rg351p.tmp" "$_f"
        log "patched $1"
    else
        rm -f "$_f.rg351p.tmp"
        log "skip $1: edit did not apply"
    fi
}

patch spruce/scripts/helperFunctions.sh \
    '^ *V10) .*POWKIDDY_V10' \
    '/^ *V10) .*POWKIDDY_V10/a\
        RG351P)           echo "ANBERNIC_RG351P"; echo "DARKMOSS" ;;'

patch spruce/scripts/emu/lib/drastic_functions.sh \
    '^run_drastic_V10()' \
    '/^run_drastic_V10()/a\
run_drastic_RG351P()    { run_drastic64 ; }'

patch App/PyUI/main-ui/devices/device_factory.py \
    'Device.init(V10(device))' \
    '/Device.init(V10(device))/a\
    elif "ANBERNIC_RG351P" == device:\
        from devices.darkmoss.rg351p import RG351P\
        Device.init(RG351P(device))'

# Case patterns: add "RG351P" right after "V10" on the line that lists the
# dArkMoss platforms.
patch App/PyUI/launch.sh \
    '"G350" | "V10"' \
    's/"G350" | "V10"/"G350" | "V10" | "RG351P"/'
patch App/AccentColor/launch.sh \
    '"G350" | "V10"' \
    's/"G350" | "V10"/"G350" | "V10" | "RG351P"/'
patch "App/-FirmwareUpdate-/firmwareUpdate.sh" \
    '"G350"|"V10"' \
    's/"G350"|"V10"/"G350"|"V10"|"RG351P"/'
patch App/Gallery/launch.sh \
    '"G350"|"V10"' \
    's/"G350"|"V10"/"G350"|"V10"|"RG351P"/'
patch App/PixelReader/launch.sh \
    '"G350"|"V10"' \
    's/"G350"|"V10"/"G350"|"V10"|"RG351P"/'
patch App/FileManagement/launch.sh \
    '|G350|V10|' \
    's/|G350|V10|/|G350|V10|RG351P|/'

# Cards set up with the first overlays seeded RetroArch's live config with
# ArkOS's 0-11 button numbering, which RetroArch 1.22 does not use for this pad
# (only the d-pad and stick worked). spruce re-seeds the live config from
# RetroArch/platform/retroarch-RG351P.cfg.bak when it is missing, so move an
# old-numbered one aside, once. Cards only: never in a spruceOS checkout.
RA_LIVE="$SD/Saves/ra-configs/retroarch-RG351P.cfg"
if [ -z "$RG351P_SPRUCE_ROOT" ] && grep -q '^input_player1_a_btn = "0"$' "$RA_LIVE" 2>/dev/null; then
    mv -f "$RA_LIVE" "$RA_LIVE.old-numbering"
    log "moved the old-numbered $RA_LIVE aside; spruce re-seeds it from the .bak"
fi

sync
touch "$STAMP" 2>/dev/null
