#!/usr/bin/env lua
-- Test script to validate WezTerm configuration loading
-- This tests module loading without requiring the full WezTerm C bindings

local results = {
  passed = {},
  failed = {},
  warnings = {}
}

local function test_module(module_path, description)
  local status, err = pcall(function()
    -- Mock wezterm if it doesn't exist
    if not package.loaded.wezterm then
      package.loaded.wezterm = {
        log_info = function(...) end,
        log_warn = function(...) end,
        log_error = function(...) end,
        config_dir = os.getenv("PWD"),
        home_dir = os.getenv("HOME"),
        hostname = function() return "localhost" end,
        target_triple = function() return "x86_64-unknown-linux-gnu" end,
        column_width = function(s) return #s end,
        truncate_right = function(s, max) return s:sub(1, max) end,
        json_encode = function(t) return "mock_json" end,
        json_parse = function(s) return {} end,
        nerdfonts = {},
        GLOBAL = {cache = {}},
        on = function() end,
        action = {},
        action_callback = function(f) return f end,
        gui = {},
        font = function(name) return {family = name} end,
        font_with_fallback = function(list) return {families = list} end,
      }
    end

    require(module_path)
  end)

  if status then
    table.insert(results.passed, {module = module_path, desc = description})
    io.write("✅ ")
  else
    table.insert(results.failed, {module = module_path, desc = description, error = tostring(err)})
    io.write("❌ ")
  end
  print(string.format("%-50s %s", module_path, description))

  if not status then
    print("   ERROR: " .. tostring(err))
  end
end

print("=" .. string.rep("=", 79))
print("WezTerm Configuration Module Loading Test")
print("=" .. string.rep("=", 79))
print()

-- Test core infrastructure
print("CORE INFRASTRUCTURE")
print("-" .. string.rep("-", 79))
test_module("config.init", "Config builder class")
test_module("config.debug", "Debug configuration")
test_module("utils.paths", "Path management")
print()

-- Test config modules
print("CONFIGURATION MODULES")
print("-" .. string.rep("-", 79))
test_module("config.appearance", "Appearance settings")
test_module("config.environment", "Environment variables")
test_module("config.font", "Font configuration")
test_module("config.general", "General settings")
test_module("config.launch", "Launch menu")
print()

-- Test utility modules
print("UTILITY MODULES")
print("-" .. string.rep("-", 79))
test_module("utils.fn", "Function utilities")
test_module("utils.table", "Table utilities")
test_module("utils.string", "String utilities")
test_module("utils.logger", "Logger")
print()

-- Test session/workspace management
print("SESSION & WORKSPACE MANAGEMENT")
print("-" .. string.rep("-", 79))
test_module("modules.sessions.manager", "Session manager")
test_module("modules.sessions.themes", "Workspace themes")
test_module("modules.sessions.bookmarks", "Bookmarks")
print()

-- Test tab management
print("TAB MANAGEMENT")
print("-" .. string.rep("-", 79))
test_module("modules.tabs.tab_manager", "Tab manager")
test_module("modules.tabs.tab_templates", "Tab templates")
test_module("modules.tabs.tab_rename", "Tab rename")
test_module("modules.tabs.tab_color_picker", "Tab color picker")
print()

-- Summary
print()
print("=" .. string.rep("=", 79))
print("SUMMARY")
print("=" .. string.rep("=", 79))
print(string.format("✅ Passed:  %d modules", #results.passed))
print(string.format("❌ Failed:  %d modules", #results.failed))
print(string.format("⚠️  Warnings: %d issues", #results.warnings))
print()

if #results.failed > 0 then
  print("FAILED MODULES:")
  for _, fail in ipairs(results.failed) do
    print(string.format("  • %s: %s", fail.module, fail.desc))
    print(string.format("    %s", fail.error))
  end
  os.exit(1)
else
  print("✅ All tests passed!")
  os.exit(0)
end
