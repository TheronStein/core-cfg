# ~/.core/zsh/integrations/systemd.zsh
# Systemd Integration - service management, journal access, and unit helpers

#=============================================================================
# CHECK FOR SYSTEMD
#=============================================================================
(($ + commands[systemctl])) || return 0

#=============================================================================
# BASE ALIASES - SYSTEM SERVICES
#=============================================================================
alias sc='systemctl'
alias scs='systemctl status'
alias scstart='systemctl start'
alias scstop='systemctl stop'
alias screstart='systemctl restart'
alias screload='systemctl reload'
alias sce='systemctl enable'
alias sced='systemctl enable --now'
alias scd='systemctl disable'
alias scdr='systemctl daemon-reload'
alias scmask='systemctl mask'
alias scunmask='systemctl unmask'
alias sccat='systemctl cat'
alias scedit='systemctl edit'
alias scshow='systemctl show'
alias sclist='systemctl list-units'
alias scfailed='systemctl --failed'
alias sctimers='systemctl list-timers'
alias scdeps='systemctl list-dependencies'

#=============================================================================
# USER SERVICES (--user flag)
#=============================================================================
alias scu='systemctl --user'
alias scus='systemctl --user status'
alias scustart='systemctl --user start'
alias scustop='systemctl --user stop'
alias scurestart='systemctl --user restart'
alias scue='systemctl --user enable'
alias scued='systemctl --user enable --now'
alias scud='systemctl --user disable'
alias scudr='systemctl --user daemon-reload'
alias sculist='systemctl --user list-units'
alias scufailed='systemctl --user --failed'
alias scutimers='systemctl --user list-timers'

#=============================================================================
# JOURNALCTL ALIASES
#=============================================================================
alias jc='journalctl'
alias jcf='journalctl -f'
alias jcu='journalctl -u'
alias jcuf='journalctl -fu'
alias jcb='journalctl -b'
alias jcb1='journalctl -b -1'
alias jce='journalctl -e'
alias jcp='journalctl -p'
alias jckerr='journalctl -p err'
alias jcuser='journalctl --user'
alias jcuserf='journalctl --user -f'
alias jcsize='journalctl --disk-usage'
alias jcvac='sudo journalctl --vacuum-size=500M'
alias jcboot='journalctl --list-boots'

#=============================================================================
# FUNCTIONS - SERVICE MANAGEMENT
#=============================================================================

# Interactive service status with fzf
function scf() {
  local unit
  unit=$(systemctl list-units --all --type=service --plain --no-legend \
    | fzf --header '╭─ System Services ─╮' \
      --preview 'SYSTEMD_COLORS=1 systemctl status $(echo {} | awk "{print \$1}") 2>/dev/null | head -30' \
      --preview-window 'right:60%:wrap' \
    | awk '{print $1}')

  [[ -n "$unit" ]] && systemctl status "$unit"
}

# Interactive user service status with fzf
function scuf() {
  local unit
  unit=$(systemctl --user list-units --all --type=service --plain --no-legend \
    | fzf --header '╭─ User Services ─╮' \
      --preview 'SYSTEMD_COLORS=1 systemctl --user status $(echo {} | awk "{print \$1}") 2>/dev/null | head -30' \
      --preview-window 'right:60%:wrap' \
    | awk '{print $1}')

  [[ -n "$unit" ]] && systemctl --user status "$unit"
}

# Quick service restart
function scr() {
  local service="$1"
  if [[ -z "$service" ]]; then
    service=$(systemctl list-units --type=service --plain --no-legend \
      | awk '{print $1}' | fzf --header '╭─ Select service to restart ─╮')
  fi
  [[ -n "$service" ]] && sudo systemctl restart "$service" && systemctl status "$service"
}

# Quick user service restart
function scur() {
  local service="$1"
  if [[ -z "$service" ]]; then
    service=$(systemctl --user list-units --type=service --plain --no-legend \
      | awk '{print $1}' | fzf --header '╭─ Select user service to restart ─╮')
  fi
  [[ -n "$service" ]] && systemctl --user restart "$service" && systemctl --user status "$service"
}

# Follow logs for a service
function jcfollow() {
  local service="$1"
  if [[ -z "$service" ]]; then
    service=$(systemctl list-units --type=service --plain --no-legend \
      | awk '{print $1}' | fzf --header '╭─ Select service for logs ─╮')
  fi
  [[ -n "$service" ]] && journalctl -fu "$service"
}

# Follow user service logs
function jcufollow() {
  local service="$1"
  if [[ -z "$service" ]]; then
    service=$(systemctl --user list-units --type=service --plain --no-legend \
      | awk '{print $1}' | fzf --header '╭─ Select user service for logs ─╮')
  fi
  [[ -n "$service" ]] && journalctl --user -fu "$service"
}

# Show service logs with bat
function jcbat() {
  local service="$1"
  local lines="${2:-100}"
  journalctl -u "$service" -n "$lines" --no-pager | bat -l log
}

# Service dependency tree
function sctree() {
  local service="${1:-default.target}"
  systemctl list-dependencies "$service" --all
}

# List all enabled services
function scenabled() {
  systemctl list-unit-files --state=enabled --type=service
}

# List all disabled services
function scdisabled() {
  systemctl list-unit-files --state=disabled --type=service
}

# Service info summary
function scinfo() {
  local service="$1"
  if [[ -z "$service" ]]; then
    # echo "Usage: scinfo <service>"
    return 1
  fi

  echo "╭─ Service Info: $service ─╮"
  systemctl show "$service" --property=Description,LoadState,ActiveState,SubState,MainPID,ExecMainStartTimestamp,MemoryCurrent 2>/dev/null \
    | while IFS='=' read -r key value; do
      printf "  %-25s %s\n" "$key:" "$value"
    done
  echo "╰────────────────────────────╯"
}

#=============================================================================
# FUNCTIONS - UNIT FILE MANAGEMENT
#=============================================================================

# Create a simple user service
function sc-create-user-service() {
  local name="$1"
  local exec_start="$2"
  local description="${3:-Custom user service}"

  if [[ -z "$name" || -z "$exec_start" ]]; then
    # echo "Usage: sc-create-user-service <name> <exec_command> [description]"
    return 1
  fi

  local service_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
  local service_file="$service_dir/${name}.service"

  mkdir -p "$service_dir"

  cat >"$service_file" <<EOF
[Unit]
Description=$description
After=default.target

[Service]
Type=simple
ExecStart=$exec_start
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

  echo "Created: $service_file"
  systemctl --user daemon-reload
  echo "Run: systemctl --user enable --now $name"
}

# Edit user service file
function sc-edit-user-service() {
  local name="$1"
  if [[ -z "$name" ]]; then
    name=$(systemctl --user list-unit-files --type=service --plain --no-legend \
      | awk '{print $1}' | fzf --header '╭─ Select service to edit ─╮')
  fi

  if [[ -n "$name" ]]; then
    local service_file="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/$name"
    [[ ! "$name" == *.service ]] && service_file="${service_file}.service"

    if [[ -f "$service_file" ]]; then
      ${EDITOR:-nvim} "$service_file"
      systemctl --user daemon-reload
    else
      echo "Service file not found: $service_file"
      echo "Use systemctl --user edit $name to create override"
    fi
  fi
}

# List user service files
function sc-user-files() {
  local service_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
  if [[ -d "$service_dir" ]]; then
    eza -la --icons "$service_dir" 2>/dev/null || ls -la "$service_dir"
  else
    echo "No user service directory: $service_dir"
  fi
}

#=============================================================================
# FUNCTIONS - TIMERS
#=============================================================================

# List active timers with details
function sc-timers() {
  echo "╭─ System Timers ─╮"
  systemctl list-timers --all
  echo ""
  echo "╭─ User Timers ─╮"
  systemctl --user list-timers --all
}

# Create a simple user timer
function sc-create-user-timer() {
  local name="$1"
  local oncalendar="${2:-daily}"

  if [[ -z "$name" ]]; then
    # echo "Usage: sc-create-user-timer <name> [OnCalendar]"
    echo "Examples for OnCalendar:"
    echo "  hourly, daily, weekly, monthly"
    echo "  *-*-* 00:00:00 (midnight daily)"
    echo "  Mon *-*-* 09:00:00 (Monday 9am)"
    return 1
  fi

  local service_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
  local timer_file="$service_dir/${name}.timer"

  mkdir -p "$service_dir"

  cat >"$timer_file" <<EOF
[Unit]
Description=Timer for $name

[Timer]
OnCalendar=$oncalendar
Persistent=true

[Install]
WantedBy=timers.target
EOF

  echo "Created: $timer_file"
  systemctl --user daemon-reload
  echo "Run: systemctl --user enable --now ${name}.timer"
}

#=============================================================================
# FUNCTIONS - BOOT AND SYSTEM ANALYSIS
#=============================================================================

# Boot time analysis
function sc-boot-time() {
  systemd-analyze
  echo ""
  systemd-analyze blame | head -20
}

# Critical chain
function sc-critical() {
  systemd-analyze critical-chain
}

# Plot boot (creates SVG)
function sc-boot-plot() {
  local output="${1:-boot-analysis.svg}"
  systemd-analyze plot >"$output"
  echo "Boot analysis saved to: $output"

  # Try to open it
  xdg-open "$output" 2>/dev/null &
}

# System state overview
function sc-overview() {
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║                    SYSTEMD OVERVIEW                          ║"
  echo "╠══════════════════════════════════════════════════════════════╣"
  echo "║ System State: $(systemctl is-system-running)"
  echo "║ Failed Units: $(systemctl --failed --plain --no-legend | wc -l)"
  echo "║ Active Units: $(systemctl list-units --state=active --plain --no-legend | wc -l)"
  echo "║ Boot Time:    $(systemd-analyze | head -1 | cut -d'=' -f2)"
  echo "╚══════════════════════════════════════════════════════════════╝"

  local failed=$(systemctl --failed --plain --no-legend)
  if [[ -n "$failed" ]]; then
    echo ""
    echo "╭─ Failed Units ─╮"
    echo "$failed"
    echo "╰─────────────────╯"
  fi
}

#=============================================================================
# FUNCTIONS - TARGETS
#=============================================================================

# List targets
function sc-targets() {
  systemctl list-units --type=target
}

# Get default target
function sc-default() {
  systemctl get-default
}

# Set default target
function sc-set-default() {
  local target="$1"
  if [[ -z "$target" ]]; then
    # echo "Usage: sc-set-default <target>"
    echo "Common targets: graphical.target, multi-user.target"
    return 1
  fi
  sudo systemctl set-default "$target"
}

#=============================================================================
# CLEANUP FUNCTIONS
#=============================================================================

# Clean old journal entries
function jc-clean() {
  echo "Current journal size:"
  journalctl --disk-usage

  read -q "?Vacuum to 500MB? [y/N] "
  echo
  if [[ $REPLY == "y" ]]; then
    sudo journalctl --vacuum-size=500M
    echo "New journal size:"
    journalctl --disk-usage
  fi
}

# Reset failed units
function sc-reset-failed() {
  systemctl reset-failed
  systemctl --user reset-failed
  echo "Reset failed unit states"
}
