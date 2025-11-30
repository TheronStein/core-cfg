# ~/.core/zsh/integrations/pacman.zsh
# Arch Linux Package Management - paru/pacman aliases and system maintenance

#=============================================================================
# DETECT PACKAGE MANAGER
# Prefer paru > yay > pacman
#=============================================================================
local PKG_MGR=""
if (( $+commands[paru] )); then
    PKG_MGR="paru"
elif (( $+commands[yay] )); then
    PKG_MGR="yay"
elif (( $+commands[pacman] )); then
    PKG_MGR="pacman"
else
    return 0
fi

#=============================================================================
# BASE ALIASES (use detected package manager)
#=============================================================================
alias p="$PKG_MGR"

#=============================================================================
# SYNC / UPDATE
#=============================================================================
alias pup="$PKG_MGR -Syu"                    # Update everything
alias pupd="$PKG_MGR -Sy"                    # Sync database only
alias pupg="$PKG_MGR -Su"                    # Upgrade only

#=============================================================================
# INSTALL
#=============================================================================
alias pin="$PKG_MGR -S"                      # Install package
alias pins="$PKG_MGR -S --needed"            # Install if not present
alias pinf="$PKG_MGR -S --overwrite '*'"     # Force install

#=============================================================================
# REMOVE
#=============================================================================
alias pre="$PKG_MGR -R"                      # Remove package
alias pres="$PKG_MGR -Rs"                    # Remove with unused deps
alias presn="$PKG_MGR -Rsn"                  # Remove with deps and configs
alias prec="$PKG_MGR -Rc"                    # Remove with dependents

#=============================================================================
# SEARCH / INFO
#=============================================================================
alias pss="$PKG_MGR -Ss"                     # Search repos
alias psi="$PKG_MGR -Si"                     # Package info (remote)
alias pqi="$PKG_MGR -Qi"                     # Package info (local)
alias pql="$PKG_MGR -Ql"                     # List package files
alias pqo="$PKG_MGR -Qo"                     # Who owns file
alias pqe="$PKG_MGR -Qe"                     # Explicitly installed
alias pqm="$PKG_MGR -Qm"                     # Foreign packages (AUR)
alias pqn="$PKG_MGR -Qn"                     # Native packages (repos)

#=============================================================================
# QUERY
#=============================================================================
alias pq="$PKG_MGR -Q"                       # List installed
alias pqs="$PKG_MGR -Qs"                     # Search installed
alias pqd="$PKG_MGR -Qd"                     # Installed as deps
alias pqt="$PKG_MGR -Qt"                     # Orphans (unrequired)
alias pqdt="$PKG_MGR -Qdt"                   # True orphans

#=============================================================================
# CACHE / CLEANUP
#=============================================================================
alias pcc="$PKG_MGR -Sc"                     # Clean old packages
alias pccc="$PKG_MGR -Scc"                   # Clean all cache
alias pcache="$PKG_MGR -Sc --noconfirm"      # Non-interactive clean

#=============================================================================
# DATABASE
#=============================================================================
alias pdb="sudo pacman -Fy"                  # Sync file database
alias pfiles="pacman -F"                     # Search file database

#=============================================================================
# FUNCTIONS
#=============================================================================

# Interactive package install with fzf
function pinf() {
    local pkg
    pkg=$($PKG_MGR -Slq | fzf --multi \
        --header '╭─ Install Packages ─╮' \
        --preview "$PKG_MGR -Si {}" \
        --preview-window 'right:60%:wrap')
    
    [[ -n "$pkg" ]] && $PKG_MGR -S ${(f)pkg}
}

# Interactive package remove with fzf
function pref() {
    local pkg
    pkg=$($PKG_MGR -Qq | fzf --multi \
        --header '╭─ Remove Packages ─╮' \
        --preview "$PKG_MGR -Qi {}" \
        --preview-window 'right:60%:wrap')
    
    [[ -n "$pkg" ]] && $PKG_MGR -Rs ${(f)pkg}
}

# Interactive package info
function psif() {
    local pkg
    pkg=$($PKG_MGR -Slq | fzf \
        --header '╭─ Package Info ─╮' \
        --preview "$PKG_MGR -Si {}" \
        --preview-window 'right:70%:wrap')
    
    [[ -n "$pkg" ]] && $PKG_MGR -Si "$pkg"
}

# Interactive local package browser
function pqf() {
    local pkg
    pkg=$($PKG_MGR -Qq | fzf \
        --header '╭─ Installed Packages ─╮' \
        --preview "$PKG_MGR -Qi {}" \
        --preview-window 'right:60%:wrap' \
        --bind 'enter:execute($PKG_MGR -Ql {} | less)')
}

# List orphan packages
function porphans() {
    local orphans=$($PKG_MGR -Qtdq)
    
    if [[ -n "$orphans" ]]; then
        echo "╭─ Orphan Packages ─╮"
        echo "$orphans" | while read -r pkg; do
            local size=$($PKG_MGR -Qi "$pkg" | grep "Installed Size" | awk '{print $4, $5}')
            printf "  %-30s %s\n" "$pkg" "$size"
        done
        echo "╰─────────────────────╯"
        echo ""
        echo "Remove with: $PKG_MGR -Rns \$($PKG_MGR -Qtdq)"
    else
        echo "No orphan packages found"
    fi
}

# Remove orphan packages
function porphan-remove() {
    local orphans=$($PKG_MGR -Qtdq)
    
    if [[ -n "$orphans" ]]; then
        echo "Orphan packages to remove:"
        echo "$orphans"
        echo ""
        read -q "?Remove all orphans? [y/N] "
        echo
        [[ $REPLY == "y" ]] && $PKG_MGR -Rns $($PKG_MGR -Qtdq)
    else
        echo "No orphan packages found"
    fi
}

# Package changelog/news
function pnews() {
    if (( $+commands[informant] )); then
        informant read
    else
        echo "Install 'informant' for Arch news"
        echo "Checking archlinux.org..."
        curl -s "https://archlinux.org/feeds/news/" | \
            grep -E "<title>|<pubDate>" | \
            sed 's/<[^>]*>//g' | \
            head -20
    fi
}

# Show package dependencies tree
function pdeps() {
    local pkg="${1:-}"
    if [[ -z "$pkg" ]]; then
        pkg=$($PKG_MGR -Qq | fzf --header '╭─ Select Package ─╮')
    fi
    
    [[ -n "$pkg" ]] && pactree "$pkg"
}

# Show reverse dependencies (what depends on package)
function prdeps() {
    local pkg="${1:-}"
    if [[ -z "$pkg" ]]; then
        pkg=$($PKG_MGR -Qq | fzf --header '╭─ Select Package ─╮')
    fi
    
    [[ -n "$pkg" ]] && pactree -r "$pkg"
}

# Find which package provides a file
function pwhich() {
    local file="${1:-}"
    if [[ -z "$file" ]]; then
        read "file?File to find: "
    fi
    
    # Check if installed
    local owner=$($PKG_MGR -Qo "$file" 2>/dev/null)
    if [[ -n "$owner" ]]; then
        echo "Installed: $owner"
    fi
    
    # Check repos
    echo "In repos:"
    pacman -F "$file"
}

# List recently installed packages
function precent() {
    local count="${1:-20}"
    expac --timefmt='%Y-%m-%d %H:%M' '%l\t%n' | sort -r | head -"$count"
}

# List explicitly installed packages
function pexplicit() {
    $PKG_MGR -Qe | less
}

# List foreign packages (AUR/manual)
function pforeign() {
    echo "╭─ Foreign Packages (AUR/Manual) ─╮"
    $PKG_MGR -Qm
    echo "╰───────────────────────────────────╯"
}

# Package size ranking
function psize() {
    local count="${1:-20}"
    expac -H M '%m\t%n' | sort -hr | head -"$count" | \
        awk '{printf "%8s  %s\n", $1, $2}'
}

# Cache size and info
function pcacheinfo() {
    echo "╭─ Package Cache Info ─╮"
    echo "  Location: /var/cache/pacman/pkg"
    echo "  Size:     $(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1)"
    echo "  Packages: $(ls /var/cache/pacman/pkg/*.zst 2>/dev/null | wc -l)"
    echo "╰────────────────────────╯"
}

# Downgrade package (requires downgrade from AUR)
function pdowngrade() {
    if (( $+commands[downgrade] )); then
        downgrade "$@"
    else
        echo "Install 'downgrade' from AUR for this feature"
    fi
}

# System upgrade with news check
function pupgrade() {
    # Check for news first
    if (( $+commands[informant] )); then
        informant check
        if [[ $? -ne 0 ]]; then
            read -q "?Continue with upgrade? [y/N] "
            echo
            [[ $REPLY != "y" ]] && return 1
        fi
    fi
    
    $PKG_MGR -Syu
}

# Full system maintenance
function pmaintenance() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                   SYSTEM MAINTENANCE                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    
    echo ""
    echo "1. Syncing package database..."
    sudo pacman -Sy
    
    echo ""
    echo "2. Checking for updates..."
    local updates=$(pacman -Qu)
    if [[ -n "$updates" ]]; then
        echo "$updates"
        echo ""
        read -q "?Install updates? [y/N] "
        echo
        [[ $REPLY == "y" ]] && $PKG_MGR -Su
    else
        echo "System is up to date"
    fi
    
    echo ""
    echo "3. Checking for orphan packages..."
    porphans
    
    echo ""
    echo "4. Cache info..."
    pcacheinfo
    
    echo ""
    echo "5. Failed systemd units..."
    systemctl --failed
    
    echo ""
    echo "Maintenance complete!"
}

# Package diff - show changes in package
function pdiff() {
    local pkg="${1:-}"
    if [[ -z "$pkg" ]]; then
        pkg=$($PKG_MGR -Qq | fzf --header '╭─ Select Package ─╮')
    fi
    
    if [[ -n "$pkg" ]]; then
        pacman -Qii "$pkg" | grep "Modified\|MODIFIED"
    fi
}

# Verify package files
function pverify() {
    local pkg="${1:-}"
    if [[ -z "$pkg" ]]; then
        pkg=$($PKG_MGR -Qq | fzf --header '╭─ Select Package ─╮')
    fi
    
    [[ -n "$pkg" ]] && pacman -Qkk "$pkg"
}

#=============================================================================
# PACMAN-SPECIFIC (if not using AUR helper)
#=============================================================================
if [[ "$PKG_MGR" == "pacman" ]]; then
    alias sudo-pin='sudo pacman -S'
    alias sudo-pre='sudo pacman -Rs'
    alias sudo-pup='sudo pacman -Syu'
fi

#=============================================================================
# MIRRORLIST MANAGEMENT
#=============================================================================

# Update mirrorlist with reflector
function pmirrors() {
    if (( $+commands[reflector] )); then
        echo "Updating mirrorlist with reflector..."
        sudo reflector \
            --country 'United States' \
            --age 12 \
            --protocol https \
            --sort rate \
            --save /etc/pacman.d/mirrorlist
        echo "Mirrorlist updated"
    else
        echo "Install 'reflector' for mirror management"
    fi
}

#=============================================================================
# ALIASES SUMMARY
#=============================================================================
function phelp() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                PACKAGE MANAGEMENT ALIASES                    ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║ SYNC/UPDATE          │ INSTALL/REMOVE                       ║"
    echo "║   pup   Full update  │   pin   Install                      ║"
    echo "║   pupd  Sync db      │   pre   Remove                       ║"
    echo "║   pupg  Upgrade only │   pres  Remove with deps             ║"
    echo "╠───────────────────────┼──────────────────────────────────────╣"
    echo "║ SEARCH/INFO          │ QUERY                                ║"
    echo "║   pss   Search       │   pq    List installed               ║"
    echo "║   psi   Remote info  │   pqs   Search installed             ║"
    echo "║   pqi   Local info   │   pqo   Who owns file                ║"
    echo "║   pql   List files   │   pqt   Orphans                      ║"
    echo "╠───────────────────────┼──────────────────────────────────────╣"
    echo "║ INTERACTIVE (fzf)    │ MAINTENANCE                          ║"
    echo "║   pinf  Install      │   porphans   Show orphans            ║"
    echo "║   pref  Remove       │   psize      Size ranking            ║"
    echo "║   pqf   Browse       │   precent    Recent installs         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
}
