#!/bin/sh
# One source, two outputs for the RG351P's spruce support:
#
#   make.sh spruce <spruceOS checkout>
#       Adds the RG351P to a spruceOS working tree, ready to commit for a pull
#       request: the new files from files/ (without the overlay-only patcher
#       and its hook) plus "RG351P" next to "V10" in the shared files. The
#       shared-file edits are RG351P-patch.sh's, run against the checkout, so
#       the PR and the overlay cannot drift apart. Fails if any edit's V10
#       anchor is missing (spruce moved on: update RG351P-patch.sh).
#
#   make.sh overlay <out.zip>
#       The zip to unpack over a spruce card that does not carry the RG351P
#       yet: the same new files, plus RG351P-patch.sh, which RG351P.cfg runs at
#       boot to make the same shared-file edits on the card.
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
FILES="$HERE/files"
PATCHER="spruce/scripts/platform/darkmoss/RG351P-patch.sh"
# Overlay-only bring-up probe: never part of the spruceOS change.
PROBE="spruce/scripts/platform/darkmoss/RG351P-probe.sh"

usage() {
    sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
    exit 2
}

[ $# -eq 2 ] || usage

case "$1" in
spruce)
    root="$(cd "$2" && pwd)"
    [ -f "$root/spruce/scripts/helperFunctions.sh" ] || { echo "$root is not a spruceOS checkout" >&2; exit 1; }

    # New files, minus the patcher and the probe; RG351P.cfg without its
    # overlay-only block.
    (cd "$FILES" && find . -type f ! -path "./$PATCHER" ! -path "./$PROBE") | while IFS= read -r f; do
        mkdir -p "$root/$(dirname "$f")"
        cp "$FILES/$f" "$root/$f"
    done
    sed -i '/^# >>> overlay only/,/^# <<< overlay only/d' \
        "$root/spruce/scripts/platform/darkmoss/RG351P.cfg"

    log="$(mktemp)"
    RG351P_SPRUCE_ROOT="$root" RG351P_PATCH_LOG="$log" sh "$FILES/$PATCHER"
    cat "$log" >&2
    if grep -q ' skip ' "$log"; then
        rm -f "$log"
        echo "Some shared files were not edited (see above)." >&2
        exit 1
    fi
    rm -f "$log"
    echo "RG351P added to $root. Review with: git -C \"$root\" status" >&2
    ;;
overlay)
    out="$2"
    case "$out" in /*) ;; *) out="$PWD/$out" ;; esac
    rm -f "$out"
    (cd "$FILES" && zip -q -r -X "$out" . -x '*/__pycache__/*')
    echo "Wrote $out" >&2
    ;;
*)
    usage
    ;;
esac
