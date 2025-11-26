-- CopilotChat TUI Module for WezTerm (Bash-Driven)
-- Spawns fzf-based bash TUI; Lua handles API via files/FIFO

local wezterm = require("wezterm")
local act = wezterm.action
local paths = require("utils.paths")

local M = {}

-- Config
M.config = {
	api = {
		provider = "copilot", -- Use GitHub Copilot
		model = "gpt-4o-2024-08-06", -- or "claude-3.5-sonnet"
		temperature = 0.1,
		max_tokens = 4096,
		github_token = nil, -- Will be fetched from 1Password or env
		copilot_token = nil, -- Cached bearer token
		copilot_token_expires = 0, -- Token expiration time
		endpoint = "https://api.githubcopilot.com/chat/completions",
		token_endpoint = "https://api.github.com/copilot_internal/v2/token",
		onepassword = {
			enabled = true,
			vault = "dev",
			items = { github = "GitHub" },
			fields = { github = "token" },
		},
	},
	ui = { position = "right", width = 0.4 },
	chat = {
		system_prompt = [[You are an AI programming assistant integrated into WezTerm.
Follow the user's requirements carefully & to the letter.
Keep responses concise but informative.
Use Markdown formatting for code blocks with language tags.
When discussing code, focus on practical solutions.]],
		save_path = wezterm.config_dir .. "/.state/copilot_chat",
	},
}

-- State
M.state = {
	chat_pane = nil,
	chat_dir = nil,
	messages = {},
	is_processing = false,
	poll_timer = nil,
	attached_files = {}, -- Files attached as context
}

-- Helpers (your originals)
local function ensure_directory(path)
	os.execute("mkdir -p '" .. path .. "'")
end

local function log(level, msg)
	local log_msg = "[CopilotChat] " .. tostring(msg)
	wezterm["log_" .. level](log_msg)

	-- Also write to file
	local log_file = wezterm.config_dir .. "/.logs/copilot-chat.log"
	ensure_directory(wezterm.config_dir .. "/.logs")
	local f = io.open(log_file, "a")
	if f then
		f:write(os.date("%Y-%m-%d %H:%M:%S") .. " [" .. level:upper() .. "] " .. log_msg .. "\n")
		f:close()
	end
end

local function get_chat_dir()
	local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
	return runtime_dir .. "/wezterm-copilot-chat-" .. os.time() -- Unique per session
end

local function read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

local function write_file(path, content)
	local dir = path:match("^(.*)/[^/]*$")
	if dir then
		ensure_directory(dir)
	end
	local file = io.open(path, "w")
	if not file then
		return false
	end
	file:write(content)
	file:close()
	return true
end

local function append_to_messages(role, content)
	-- Ensure messages table exists
	if not M.state.messages or type(M.state.messages) ~= "table" then
		log("warn", "Messages table was corrupted, reinitializing")
		M.state.messages = {}
	end

	local timestamp = os.date("%H:%M:%S")
	local msg_file = M.state.chat_dir .. "/messages.txt"
	-- Escape pipes and newlines for storage in single-line format
	local escaped_content = content:gsub("|", "\\|"):gsub("\n", "\\n")
	local line = string.format("%s|%s|%s\n", role, timestamp, escaped_content)
	local file = io.open(msg_file, "a")
	if file then
		file:write(line)
		file:close()
		table.insert(M.state.messages, { role = role, content = content, timestamp = timestamp })
		return true
	end
	return false
end

-- API Client (your simplified version)
local ApiClient = {}
ApiClient.__index = ApiClient

function ApiClient:new(config)
	local self = setmetatable({}, ApiClient)
	self.config = config
	return self
end

function ApiClient:get_github_token()
	if self.config.github_token then
		log("info", "Using cached GitHub token")
		return self.config.github_token
	end

	-- Check GitHub Copilot cached tokens (same as CopilotChat.nvim)
	local config_paths = {
		paths.GITHUB_COPILOT_CONFIG .. "/hosts.json",
		paths.GITHUB_COPILOT_CONFIG .. "/apps.json",
	}

	for _, path in ipairs(config_paths) do
		log("info", "Checking for GitHub Copilot token in: " .. path)
		-- Use jq to extract token directly (more reliable than Lua JSON in timer context)
		local cmd = string.format("jq -r 'to_entries[] | select(.key | contains(\"github.com\")) | .value.oauth_token // empty' '%s' 2>/dev/null", path)
		log("info", "Running: " .. cmd)
		local handle = io.popen(cmd)
		if handle then
			local token = handle:read("*a"):gsub("^%s*(.-)%s*$", "%1")
			handle:close()
			if token and token ~= "" then
				log("info", "Found GitHub Copilot token in " .. path .. " (length: " .. #token .. ")")
				self.config.github_token = token
				return token
			else
				log("info", "No oauth_token found in " .. path)
			end
		else
			log("error", "Failed to execute jq command for " .. path)
		end
	end

	-- Try environment variable
	local env_token = os.getenv("GITHUB_TOKEN")
	if env_token then
		log("info", "Using GitHub token from environment variable")
		self.config.github_token = env_token
		return env_token
	end

	log("error", "No GitHub Copilot token found. Please authenticate with GitHub Copilot first.")
	return nil
end

function ApiClient:get_copilot_token()
	-- Check if cached token is still valid
	if self.config.copilot_token and os.time() < self.config.copilot_token_expires then
		log("info", "Using cached Copilot token")
		return self.config.copilot_token
	end

	-- Get GitHub token
	local github_token = self:get_github_token()
	if not github_token then
		return nil, "No GitHub token available"
	end

	-- Request Copilot token
	log("info", "Requesting Copilot token from GitHub API")
	local cmd = string.format(
		[[curl -s -X GET "%s" -H "Authorization: token %s" -H "Accept: application/json"]],
		self.config.token_endpoint,
		github_token
	)

	local handle = io.popen(cmd)
	if not handle then
		return nil, "Failed to execute token request"
	end

	local response = handle:read("*a")
	handle:close()

	log("info", "Token response: " .. response:sub(1, 100))

	local ok, data = pcall(function() return wezterm.json_parse(response) end)
	if not ok or not data then
		log("error", "Failed to parse token response: " .. tostring(data))
		return nil, "Failed to parse token response"
	end

	if data.token and data.expires_at then
		self.config.copilot_token = data.token
		-- Parse expires_at (Unix timestamp)
		self.config.copilot_token_expires = data.expires_at
		log("info", "Successfully obtained Copilot token")
		return data.token
	end

	return nil, "No token in response"
end

function ApiClient:complete(messages, callback)
	-- Get Copilot token
	local token, err = self:get_copilot_token()
	if not token then
		log("error", "Failed to get Copilot token: " .. tostring(err))
		callback(nil, "Authentication failed: " .. tostring(err))
		return
	end

	log("info", "Creating API request with model: " .. self.config.model)

	-- GitHub Copilot API format with streaming
	local payload = {
		model = self.config.model,
		messages = messages,
		temperature = self.config.temperature,
		max_tokens = self.config.max_tokens,
		stream = true,
		n = 1,
	}

	local temp_file = os.tmpname()
	write_file(temp_file, wezterm.json_encode(payload))
	log("info", "Sending request to: " .. self.config.endpoint)

	local msg_file = M.state.chat_dir .. "/messages.txt"
	local timestamp = os.date("%H:%M:%S")
	local accumulated_content = ""
	local stream_output = M.state.chat_dir .. "/stream_output.txt"

	-- Start curl in background, streaming to file
	local curl_cmd = string.format(
		"curl -s -N --no-buffer -X POST '%s' " ..
		"-H 'Content-Type: application/json' " ..
		"-H 'Authorization: Bearer %s' " ..
		"-H 'Editor-Version: Neovim/0.10.0' " ..
		"-H 'Editor-Plugin-Version: CopilotChat.nvim/*' " ..
		"-H 'Copilot-Integration-Id: vscode-chat' " ..
		"-d @'%s' > '%s' 2>&1 &",
		self.config.endpoint,
		token,
		temp_file,
		stream_output
	)

	log("info", "Starting streaming request")
	os.execute(curl_cmd)

	-- Poll the output file for streaming data
	local last_read_pos = 0
	local poll_count = 0
	local max_polls = 600 -- 60 seconds at 0.1s intervals

	local function poll_stream()
		poll_count = poll_count + 1

		-- Check if we've exceeded max polls
		if poll_count > max_polls then
			log("error", "Stream timeout after " .. max_polls .. " polls")
			os.remove(stream_output)
			os.remove(temp_file)
			callback(nil, "Request timed out")
			return
		end

		local handle = io.open(stream_output, "r")
		if not handle then
			wezterm.time.call_after(0.1, poll_stream)
			return
		end

		-- Seek to last position and read new data
		handle:seek("set", last_read_pos)
		local new_data = handle:read("*a")
		last_read_pos = handle:seek()
		handle:close()

		if new_data and #new_data > 0 then
			-- Process each line
			for line in new_data:gmatch("[^\r\n]+") do
				line = line:gsub("^%s*", ""):gsub("%s*$", "")  -- trim

				-- Skip event names and comments
				if line:match("^event:") or line:match("^:") or line == "" then
					goto continue
				end

				-- Extract data from SSE format
				local data = line:match("^data:%s*(.+)$") or line

				-- Check for stream end
				if data == "[DONE]" then
					log("info", "Stream completed, length: " .. #accumulated_content)
					os.remove(stream_output)
					os.remove(temp_file)

					if #accumulated_content > 0 then
						callback({ content = accumulated_content, role = "assistant" })
					else
						callback(nil, "Empty response from API")
					end
					return
				end

				-- Parse JSON chunk
				local ok, chunk = pcall(wezterm.json_parse, data)
				if ok and chunk and chunk.choices and #chunk.choices > 0 then
					local delta = chunk.choices[1].delta
					if delta and delta.content then
						accumulated_content = accumulated_content .. delta.content

						-- Escape content for storage
						local escaped = accumulated_content:gsub("|", "\\|"):gsub("\n", "\\n")

						-- Update or create assistant message
						local file = io.open(msg_file, "r")
						local content = file and file:read("*a") or ""
						if file then file:close() end

						-- Remove thinking and existing assistant messages
						content = content:gsub("thinking|[^\n]*\n", "")
						content = content:gsub("assistant|[^\n]*\n", "")

						-- Append new assistant message
						file = io.open(msg_file, "w")
						if file then
							file:write(content)
							file:write(string.format("assistant|%s|%s\n", timestamp, escaped))
							file:close()
						end
					end
				end

				::continue::
			end
		end

		-- Continue polling
		wezterm.time.call_after(0.1, poll_stream)
	end

	-- Start polling after a short delay
	wezterm.time.call_after(0.2, poll_stream)
end

-- Process input
function M:process_input(input)
	input = input:gsub("^%s*(.-)%s*$", "%1")
	if input == "" then
		return
	end

	if input:sub(1, 1) == "/" then
		local cmd = input:sub(2):lower()
		if cmd == "help" then
			append_to_messages("system", [[Commands: /help /clear /reset /model /exit

File References:
  #file:/path/to/file - Attach file as context
  Example: "explain this #file:~/config.lua"]])
		end
		if cmd == "clear" then
			write_file(M.state.chat_dir .. "/messages.txt", "")
			M.state.messages = {}
			append_to_messages("system", "Chat cleared")
		end
		if cmd == "reset" then
			write_file(M.state.chat_dir .. "/messages.txt", "")
			M.state.messages = {}
			append_to_messages("system", "Session reset")
		end
		if cmd == "model" then
			local models = { "gpt-4o-2024-08-06", "gpt-4-turbo-preview", "gpt-4", "gpt-3.5-turbo" }
			local current = self.config.api.model
			local next_index = 1
			for i, model in ipairs(models) do
				if model == current then
					next_index = (i % #models) + 1
					break
				end
			end
			self.config.api.model = models[next_index]
			append_to_messages("system", "Model: " .. self.config.api.model)
		end
		if cmd == "exit" then
			M:close()
		end
		return
	end

	if self.state.is_processing then
		append_to_messages("system", "Still processing previous request...")
		return
	end

	self.state.is_processing = true

	-- Extract file references (#file:path)
	local file_refs = {}
	local clean_input = input:gsub("#file:([^%s]+)", function(path)
		-- Expand ~ to home directory
		local expanded_path = path:gsub("^~", os.getenv("HOME") or "~")
		table.insert(file_refs, expanded_path)
		return "" -- Remove from message
	end):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1") -- Clean up whitespace

	append_to_messages("user", input) -- Store original with references
	append_to_messages("thinking", "Waiting for response...")

	-- Ensure messages table is valid
	if not M.state.messages or type(M.state.messages) ~= "table" then
		log("error", "Messages table corrupted before API call")
		M.state.messages = {}
	end

	-- Build API messages with file context
	local api_messages = { { role = "system", content = self.config.chat.system_prompt } }

	-- Add file references as context
	for _, file_path in ipairs(file_refs) do
		local file = io.open(file_path, "r")
		if file then
			local content = file:read("*a")
			file:close()

			-- Detect file type from extension
			local ext = file_path:match("%.([^%.]+)$") or "txt"
			local context_msg = string.format("# File: %s\n```%s\n%s\n```", file_path, ext, content)

			table.insert(api_messages, { role = "user", content = context_msg })
			log("info", "Attached file: " .. file_path .. " (" .. #content .. " bytes)")
		else
			log("warn", "Could not read file: " .. file_path)
			append_to_messages("system", "Warning: Could not read file: " .. file_path)
		end
	end

	-- Add chat history
	for _, msg in ipairs(M.state.messages) do
		if msg.role == "user" or msg.role == "assistant" then
			table.insert(api_messages, { role = msg.role, content = msg.content })
		end
	end

	-- Run API call in background (non-blocking)
	local client = ApiClient:new(self.config.api)
	client:complete(api_messages, function(response, err)
		self.state.is_processing = false

		if response then
			append_to_messages("assistant", response.content)
		else
			append_to_messages("error", "API Error: " .. (err or "Unknown"))
		end
	end)
end

-- Poll FIFO
function M:start_polling()
	if not M.state.chat_dir then
		log("error", "Cannot start polling: chat_dir not set")
		return
	end

	local command_fifo = M.state.chat_dir .. "/command.fifo"

	-- Create a recurring polling function
	local function poll()
		local success, err = pcall(function()
			local handle = io.popen("timeout 0.1 cat " .. command_fifo .. " 2>/dev/null")
			if handle then
				local input = handle:read("*a")
				handle:close()
				if input and input ~= "" then
					log("info", "Received input from FIFO: " .. input)
					M:process_input(input)
				end
			end
		end)

		if not success then
			log("error", "Polling error: " .. tostring(err))
		end

		-- Schedule next poll if still open
		if M.state.chat_pane then
			M.state.poll_timer = wezterm.time.call_after(0.5, poll)
		end
	end

	log("info", "Starting FIFO polling for: " .. command_fifo)
	M.state.poll_timer = wezterm.time.call_after(0.5, poll)
end

-- Open chat
function M:open(window, pane)
	if M.state.chat_pane then
		log("info", "Chat already open")
		M.state.chat_pane:activate()
		return
	end

	M.state.chat_dir = get_chat_dir()
	ensure_directory(M.state.chat_dir)
	write_file(M.state.chat_dir .. "/messages.txt", "")
	os.execute("mkfifo '" .. M.state.chat_dir .. "/command.fifo' 2>/dev/null || true")

	append_to_messages("system", "Welcome to Copilot Chat! Type /help for commands.")

	local tui_script = wezterm.config_dir .. "/scripts/copilot-chat-tui.sh" -- Place script here
	if not write_file(tui_script, read_file(tui_script) or "") then -- Ensure exists; you provide it
		log("error", "Missing copilot-chat-tui.sh; create it based on below.")
		return
	end
	os.execute("chmod +x '" .. tui_script .. "'")

	local direction = "Right"
	local size_percent = 40
	if M.config.ui and M.config.ui.width then
		size_percent = math.floor(M.config.ui.width * 100)
	end
	if M.config.ui and M.config.ui.position == "bottom" then
		direction = "Bottom"
		size_percent = 30
	end

	-- Use SplitPane action - same pattern as toggle_terminal
	log("info", "Creating chat pane with direction=" .. direction .. " size=" .. size_percent)

	window:perform_action(
		act.SplitPane({
			direction = direction,
			command = { args = { "bash", tui_script, M.state.chat_dir } },
			size = { Percent = size_percent },
		}),
		pane
	)

	-- Get the newly created pane (same as toggle_terminal line 336)
	local new_pane = window:active_pane()
	if new_pane then
		M.state.chat_pane = new_pane
		log("info", "Chat pane created successfully with ID: " .. new_pane:pane_id())
	else
		log("error", "Failed to get active pane after split")
		return
	end

	log("info", "About to start polling...")
	M:start_polling()
	log("info", "Chat TUI opened")
end

function M:close()
	log("info", "Closing chat and stopping polling")
	if M.state.poll_timer then
		-- Cancel the timer properly
		pcall(function() M.state.poll_timer:cancel() end)
		M.state.poll_timer = nil
	end

	if M.state.chat_pane then
		-- Guard: Check if pane still exists/valid before ops
		local pane_id = nil
		local success, err = pcall(function()
			pane_id = M.state.chat_pane:pane_id()
		end)

		if success and pane_id then
			-- Pane is still valid, try to close it
			local window = wezterm.mux.get_window(0)
			if window then
				pcall(function()
					window:perform_action(act.CloseCurrentPane({ confirm = false }), M.state.chat_pane)
				end)
			end
		else
			log("warn", "Stale chat pane; skipping close: " .. tostring(err))
		end

		-- Reset state
		M.state.chat_pane = nil
		M.state.source_pane = nil
		M.state.source_tab = nil

		-- Cleanup dir/FIFO
		if M.state.chat_dir then
			os.execute("rm -rf '" .. M.state.chat_dir .. "'")
			M.state.chat_dir = nil
		end

		log("info", "Chat closed")
	else
		log("info", "No chat pane to close")
	end
end

function M:toggle(window, pane)
	if M.state.chat_pane then
		-- Guard: Verify pane exists before closing
		local pane_id = nil
		local success, err = pcall(function()
			pane_id = M.state.chat_pane:pane_id()
		end)
		if success and pane_id then
			self:close()
		else
			log("warn", "Stale pane in toggle; forcing reset")
			M.state.chat_pane = nil -- Force-clear stale ref
			-- Cleanup dir if needed
			if M.state.chat_dir then
				os.execute("rm -rf '" .. M.state.chat_dir .. "'")
				M.state.chat_dir = nil
			end
		end
	else
		self:open(window, pane)
	end
end

function M:setup(config)
	if config then
		-- Merge (shallow)
		for k, v in pairs(config) do
			if type(v) == "table" and type(self.config[k]) == "table" then
				for k2, v2 in pairs(v) do
					self.config[k][k2] = v2
				end
			else
				self.config[k] = v
			end
		end
	end
	log("info", "CopilotChat TUI initialized with provider=" .. self.config.api.provider .. " endpoint=" .. self.config.api.endpoint)
	return self
end

return M
