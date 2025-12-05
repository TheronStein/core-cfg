#!/usr/bin/env -S wezterm shell-completion --shell bash
-- Test script for workspace isolation functionality
-- Run this with: wezterm cli spawn --new-window -- lua test-workspace-isolation.lua

local wezterm = require("wezterm")
local paths = require("utils.paths")

print("===============================================")
print("WORKSPACE ISOLATION TEST")
print("===============================================")

-- Test 1: Load isolation module
print("\n[TEST 1] Loading workspace_isolation module...")
local ok_isolation, isolation = pcall(require, "modules.sessions.workspace_isolation")
if ok_isolation then
	print("✅ workspace_isolation module loaded successfully")
else
	print("❌ FAILED to load workspace_isolation: " .. tostring(isolation))
	os.exit(1)
end

-- Test 2: Check if isolation is available
print("\n[TEST 2] Checking if isolation is available...")
local is_available = isolation.is_isolation_available()
if is_available then
	print("✅ Isolation is available (wezterm cli is working)")
else
	print("❌ Isolation is NOT available (wezterm cli not working)")
end

-- Test 3: Get running clients
print("\n[TEST 3] Getting running clients...")
local clients = isolation.get_running_clients()
print("Found " .. #clients .. " running client(s):")
for i, client in ipairs(clients) do
	print(string.format("  %d. Window ID: %d, Workspace: %s", i, client.window_id, client.workspace))
end

-- Test 4: Get active workspace names
print("\n[TEST 4] Getting active workspace names...")
local workspaces = isolation.get_active_workspace_names()
print("Found " .. #workspaces .. " active workspace(s):")
for i, ws in ipairs(workspaces) do
	print(string.format("  %d. %s", i, ws))
end

-- Test 5: Test finding client for workspace
print("\n[TEST 5] Testing client lookup for 'default' workspace...")
local default_client = isolation.find_client_for_workspace("default")
if default_client then
	print("✅ Found client for 'default' workspace: window_id = " .. default_client)
else
	print("⚠️  No client found for 'default' workspace")
end

-- Test 6: Load workspace_manager module
print("\n[TEST 6] Loading workspace_manager module...")
local ok_manager, workspace_manager = pcall(require, "modules.sessions.workspace_manager")
if ok_manager then
	print("✅ workspace_manager module loaded successfully")
	print("   ISOLATION MODE: " .. (workspace_manager.ENABLE_ISOLATION and "ENABLED" or "DISABLED"))
else
	print("❌ FAILED to load workspace_manager: " .. tostring(workspace_manager))
	os.exit(1)
end

print("\n===============================================")
print("ALL TESTS COMPLETED")
print("===============================================")
