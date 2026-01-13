#!/usr/bin/env bash
# --------------------------------------------------------------------
#  Arch "Spring-Clean" Maintenance Script  —  Samuel Edition
# --------------------------------------------------------------------
#  • Interactive, abort-safe, logs to file
#  • Optional system upgrade (--upgrade)
#  • Optional dry-run preview (--dry)
#  • Detects paru or yay
#  • Requires: pacman-contrib, pacdiff, detected AUR helper
# --------------------------------------------------------------------

set -uo pipefail
trap 'echo -e "\n[!] Aborted"; exit 1' INT TERM

# ---------------------- Detect AUR helper -----------------------------------
detect_aur() {
    for helper in paru yay; do
        if command -v "$helper" >/dev/null 2>&1; then
            echo "$helper"
            return
        fi
    done
    echo "Error: Neither paru nor yay found." >&2
    exit 1
}
AUR=$(detect_aur)
# -----------------------------------------------------------------------------

# ---------------------- Config ----------------------------------------------
LOG_DIR="$HOME/.local/var/log/arch-maintenance"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/clean-$(date +%F_%H-%M-%S).log"

PACCACHE_RETAIN=2
CACHE_DAYS=30
JOURNAL_RETAIN="7d"

# -----------------------------------------------------------------------------

exec > >(tee -a "$LOG_FILE") 2>&1

confirm() {
    read -r -p "${1:-Proceed? [y/N]} " ans
    [[ "$ans" =~ ^([yY]|[yY][eE][sS])$ ]]
}

announce() {
    printf "\n\e[1;34m==> %s\e[0m\n" "$1"
}

# ---------------------- CLI --------------------------------------------------
DO_UPGRADE=false
DRY=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--upgrade) DO_UPGRADE=true ;;
        --dry) DRY=true ;;
        -h|--help)
            echo "Usage: $0 [--upgrade] [--dry]"
            exit 0
            ;;
        *) echo "Unknown option: $1" ; exit 2 ;;
    esac
    shift
done

announce "Arch Spring-Clean — $(date)"
echo "AUR helper: $AUR ($(command -v $AUR))"
echo "Dry run: $DRY"
echo

# ---------------------- 1. Optional upgrade ---------------------------------
if $DO_UPGRADE; then
    announce "System upgrade ($AUR)"
    if $DRY; then
        echo "[dry] $AUR -Syu --ask 4"
    else
        $AUR -Syu --ask 4
    fi
fi

# ---------------------- 2. Pacman cache trim --------------------------------
announce "Pacman cache trim (keep $PACCACHE_RETAIN versions)"
current_cache=$(du -sh /var/cache/pacman/pkg | cut -f1)
echo "Current cache: $current_cache"

if confirm "Clean pacman cache? [y/N]"; then
    if $DRY; then
        echo "[dry] sudo paccache -vrk $PACCACHE_RETAIN"
        echo "[dry] sudo paccache -ruk 0"
    else
        sudo paccache -vrk "$PACCACHE_RETAIN"
        sudo paccache -ruk0
    fi
fi

new_cache=$(du -sh /var/cache/pacman/pkg | cut -f1)
echo "Cache after: $new_cache"

# ---------------------- 3. Orphaned packages --------------------------------
announce "Checking for orphans…"
mapfile -t ORPHANS < <($AUR -Qtdq || true)

if ((${#ORPHANS[@]})); then
    printf "Found %d orphan(s): %s\n" "${#ORPHANS[@]}" "${ORPHANS[*]}"
    if confirm "Remove orphan packages? [y/N]"; then
        if $DRY; then
            echo "[dry] sudo pacman -Rns ${ORPHANS[*]}"
        else
            sudo pacman -Rns "${ORPHANS[@]}"
        fi
    fi
else
    echo "No orphans found."
fi

# ---------------------- 4. ~/.cache prune -----------------------------------
announce "Pruning ~/.cache (older than $CACHE_DAYS days)"
cache_before=$(du -sh ~/.cache | cut -f1)
echo "Before: $cache_before"

if confirm "Clean ~/.cache now? [y/N]"; then
    if $DRY; then
        echo "[dry] find ~/.cache -type f -mtime +$CACHE_DAYS -delete"
    else
        find ~/.cache -type f -mtime +"$CACHE_DAYS" -print -delete
        find ~/.cache -type d -empty -print -delete
    fi
fi

cache_after=$(du -sh ~/.cache | cut -f1)
echo "After: $cache_after"

# ---------------------- 5. Journald vacuum ----------------------------------
announce "Vacuuming journald logs (retain: $JOURNAL_RETAIN)"
journal_before=$(journalctl --disk-usage | awk '{print $NF}')

if confirm "Vacuum journald now? [y/N]"; then
    if $DRY; then
        echo "[dry] sudo journalctl --rotate"
        echo "[dry] sudo journalctl --vacuum-time=$JOURNAL_RETAIN"
    else
        sudo journalctl --rotate
        sudo journalctl --vacuum-time="$JOURNAL_RETAIN"
    fi
fi

journal_after=$(journalctl --disk-usage | awk '{print $NF}')
echo "Journald: $journal_before -> $journal_after"

# ---------------------- 6. Failed units -------------------------------------
announce "Checking failed systemd units"
if systemctl --failed --quiet; then
    echo "No failed units."
else
    systemctl --failed --no-pager --plain
fi

# ---------------------- Summary ---------------------------------------------
announce "Summary"
echo "  • Log saved to: $LOG_FILE"
echo "  • Duration: ${SECONDS}s"
echo "  • Dry run: $DRY"

announce "Spring-Clean complete"
