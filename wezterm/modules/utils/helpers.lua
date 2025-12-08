local M = {}

-- Helper: Convert icon key to actual character, or return as-is if already a character
local function resolve_icon(icon_value)
  if not icon_value or icon_value == "" then
    return wezterm.nerdfonts.md_bash -- Default to bash icon
  end

  -- If it's already a single unicode character (not a key), return it
  if #icon_value <= 4 then -- Unicode chars are typically 1-4 bytes in UTF-8
    return icon_value
  end

  -- Try to resolve as nerdfonts key (e.g., "md_bash" -> actual character)
  local resolved = wezterm.nerdfonts[icon_value]
  if resolved then
    wezterm.log_info("Resolved icon key '" .. icon_value .. "' to character")
    return resolved
  end

  -- Fallback: return as-is (might be the character itself)
  return icon_value
end

M.resolve_icon = resolve_icon
