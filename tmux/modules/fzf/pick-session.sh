#!/bin/bash

# Get all windows across all sessions with details
SESSIONS=$(tmux list-windows -a -F "#{session_name}:#{window_index} #{window_name} #{pane_current_path}")
