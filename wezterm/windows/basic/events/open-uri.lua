local wezterm = require"wezterm"

local M = {}

function M.setup()
  wezterm.on("open-uri", function(window, pane, uri)
    local editor = os.getenv("EDITOR") or "nvim"

    if uri:find("^file:") == 1 and not pane:is_alt_screen_active() then
      local url = wezterm.url.parse(uri)
      if is_shell(pane:get_foreground_process_name()) then
        local success, stdout, _ = wezterm.run_child_process({
          "file",
          "--brief",
          "--mime-type",
          url.file_path,
        })
        if success then
          if stdout:find("directory") then
            pane:send_text(wezterm.shell_join_args({ "cd", url.file_path }) .. "\r")
            pane:send_text(wezterm.shell_join_args({
              "ls",
              "-la",
              "--color=auto",
              "--group-directories-first",
            }) .. "\r")
            return false
          end
          if stdout:find("text") then
            if url.fragment then
              pane:send_text(wezterm.shell_join_args({
                editor,
                "+" .. url.fragment,
                url.file_path,
              }) .. "\r")
            else
              pane:send_text(wezterm.shell_join_args({ editor, url.file_path }) .. "\r")
            end
            return false
          end
        end
      else
        local edit_cmd = url.fragment and editor .. " +" .. url.fragment .. ' "$_f"' or editor .. ' "$_f"'
        local cmd = '_f="'
          .. url.file_path
          .. '"; { test -d "$_f" && { cd "$_f" ; ls -la --color=auto --group-directories-first; }; } '
          .. '|| { test "$(file --brief --mime-type "$_f" | cut -d/ -f1 || true)" = "text" && '
          .. edit_cmd
          .. "; }; echo"
        pane:send_text(cmd .. "\r")
        return false
      end
    end
  end)
end

return M
