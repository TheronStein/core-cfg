# this is used to get "clean" integer version number. Examples:
# `tmux 1.9` => `19`
# `1.9a`     => `19`
get_digits_from_string() {
  local string="$1"
  local only_digits="$(echo "$string" | tr -dC '[:digit:]')"
  echo "$only_digits"
}
