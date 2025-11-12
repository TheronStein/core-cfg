# ~/.core/cfg/zsh/zsh.d/35-syntax-highlighting.zsh
# Syntax highlighting color configuration

# This function will be called after fast-syntax-highlighting loads
setup_syntax_colors() {
  # Only configure if the plugin is loaded
  if [[ -n "${FAST_HIGHLIGHT_STYLES}" ]]; then
    # Fast-syntax-highlighting color settings
    # Change the default (unknown-token) color from near-black to something more visible
    typeset -g FAST_HIGHLIGHT_STYLES[default]='fg=250'          # Light gray for normal text
    typeset -g FAST_HIGHLIGHT_STYLES[unknown-token]='fg=004'    # Light gray for unrecognized text
    # Other syntax colors you might want to customize
    typeset -g FAST_HIGHLIGHT_STYLES[commandseparator]='fg=189'
    typeset -g FAST_HIGHLIGHT_STYLES[redirection]='fg=229'
    typeset -g FAST_HIGHLIGHT_STYLES[here-string-tri]='fg=228'
    typeset -g FAST_HIGHLIGHT_STYLES[here-string-text]='fg=229'
    typeset -g FAST_HIGHLIGHT_STYLES[here-string-var]='fg=231'
    typeset -g FAST_HIGHLIGHT_STYLES[exec-descriptor]='fg=226,bold'
    typeset -g FAST_HIGHLIGHT_STYLES[comment]='fg=30,bold'
    typeset -g FAST_HIGHLIGHT_STYLES[correct-subtle]='fg=46'
    typeset -g FAST_HIGHLIGHT_STYLES[incorrect-subtle]='fg=198'
    typeset -g FAST_HIGHLIGHT_STYLES[command]='fg=87'
    typeset -g FAST_HIGHLIGHT_STYLES[alias]='fg=147'
    typeset -g FAST_HIGHLIGHT_STYLES[suffix-alias]='fg=153'
    typeset -g FAST_HIGHLIGHT_STYLES[builtin]='fg=216'
    typeset -g FAST_HIGHLIGHT_STYLES[function]='fg=221'
    typeset -g FAST_HIGHLIGHT_STYLES[command-substitution]='fg=162'
    typeset -g FAST_HIGHLIGHT_STYLES[command-substitution-unquoted]='fg=168'
    typeset -g FAST_HIGHLIGHT_STYLES[path]='fg=154'
    typeset -g FAST_HIGHLIGHT_STYLES[path-to-dir]='fg=118,underline'
    typeset -g FAST_HIGHLIGHT_STYLES[globbing]='fg=73,bold'
    typeset -g FAST_HIGHLIGHT_STYLES[single-hyphen-option]='fg=72'
    typeset -g FAST_HIGHLIGHT_STYLES[double-hyphen-option]='fg=73'
    typeset -g FAST_HIGHLIGHT_STYLES[back-quoted-argument]='fg=75'
    typeset -g FAST_HIGHLIGHT_STYLES[single-quoted-argument]='fg=227'
    typeset -g FAST_HIGHLIGHT_STYLES[double-quoted-argument]='fg=191'
    typeset -g FAST_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=119'
    typeset -g FAST_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=119'
    typeset -g FAST_HIGHLIGHT_STYLES[variable]='fg=203'
    typeset -g FAST_HIGHLIGHT_STYLES[assign]='fg=121'
    typeset -g FAST_HIGHLIGHT_STYLES[reserved-word]='fg=57,bold'
  fi
}

# Try to set it up immediately if plugin is loaded
setup_syntax_colors

# Also hook it to run after the plugin loads (if not loaded yet)
if [[ -z "${FAST_HIGHLIGHT_STYLES}" ]]; then
    # Add a hook to configure after fast-syntax-highlighting loads
    typeset -ga precmd_functions
    configure_syntax_after_load() {
        if [[ -n "${FAST_HIGHLIGHT_STYLES}" ]]; then
            setup_syntax_colors
          # Remove this function from precmd after it runs
            precmd_functions=(${precmd_functions:#configure_syntax_after_load})
        fi
    }
    precmd_functions+=(configure_syntax_after_load)
fi
