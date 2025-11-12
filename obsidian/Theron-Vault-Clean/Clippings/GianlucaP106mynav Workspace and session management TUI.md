---
title: "GianlucaP106/mynav: Workspace and session management TUI"
source: "https://github.com/GianlucaP106/mynav"
author:
  - "[[GianlucaP106]]"
published:
created: 2025-06-14
description: "Workspace and session management TUI. Contribute to GianlucaP106/mynav development by creating an account on GitHub."
tags:
  - "clippings"
---
Workspace and session management TUI

[MIT license](https://github.com/GianlucaP106/mynav/blob/main/LICENSE)

[Open in github.dev](https://github.dev/) [Open in a new github.dev tab](https://github.dev/) [Open in codespace](https://github.com/codespaces/new/GianlucaP106/mynav?resume=1)

## MyNav 🧭

A powerful terminal-based workspace navigator and session manager built in Go. MyNav helps developers organize and manage multiple projects through an intuitive interface, seamlessly integrating with tmux sessions.

[![demo](https://private-user-images.githubusercontent.com/93693693/389351062-c2482080-6c1d-4fda-a3d5-e0ae6d8a916b.gif?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDk4OTI0NjUsIm5iZiI6MTc0OTg5MjE2NSwicGF0aCI6Ii85MzY5MzY5My8zODkzNTEwNjItYzI0ODIwODAtNmMxZC00ZmRhLWEzZDUtZTBhZTZkOGE5MTZiLmdpZj9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA2MTQlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwNjE0VDA5MDkyNVomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTY4ZGU3ZTlmM2NjN2VlYjEwODVlNDNmODI3NTA4YmNkMDJkYTcwYzcyZjdhNzRmMDZmOTI1NjhmNzFkNmZlZGEmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.T_yKX3ruc4PBKIt0msrt4WipJ9WAInkjQq3YNOVPv_0)](https://private-user-images.githubusercontent.com/93693693/389351062-c2482080-6c1d-4fda-a3d5-e0ae6d8a916b.gif?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDk4OTI0NjUsIm5iZiI6MTc0OTg5MjE2NSwicGF0aCI6Ii85MzY5MzY5My8zODkzNTEwNjItYzI0ODIwODAtNmMxZC00ZmRhLWEzZDUtZTBhZTZkOGE5MTZiLmdpZj9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA2MTQlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwNjE0VDA5MDkyNVomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTY4ZGU3ZTlmM2NjN2VlYjEwODVlNDNmODI3NTA4YmNkMDJkYTcwYzcyZjdhNzRmMDZmOTI1NjhmNzFkNmZlZGEmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.T_yKX3ruc4PBKIt0msrt4WipJ9WAInkjQq3YNOVPv_0)

Before creating mynav, I often found myself frustrated when working on multiple projects using tmux, as I had to manually navigate between project directories. While tmux’s choose-tree feature allows jumping between active sessions, it relies on the tmux server staying alive and doesn't fully meet the needs of a robust workspace manager. mynav bridges this gap by combining tmux's powerful features with a workspace management system, enabling a more efficient and streamlined development workflow in a terminal environment.

## ✨ Features

- 📁 **Workspace Management**
	- Group workspaces into topics
	- Quick workspace creation and navigation
	- Lives directly on your filesystem
- 💻 **Advanced Session Management**
	- Create, modify, delete and enter sessions seamlessly
	- Live session preview with window/pane information
	- Fast session switching
- 🔧 **Developer Experience**
	- Fuzzy search workspaces and sessions
	- Built on tmux
	- Extensive keyboard shortcuts
	- Git integration
	- Clean, intuitive Lazygit-like terminal UI
	- Vim-style navigation

### One-Line Installation

### Manual Installation

### Prerequisites

- Tmux 3.0+
- Git (optional, for repository features)
- Terminal with UTF-8 support

---

## 📖 Usage

Mynav requires a root directory to initialize in. You may initialize multiple directories but not nested. You can start mynav anywhere with:

```
mynav
```

> This will look for an existing configuration if it exists (in the current or any parent directory).

You may specify a directory to launch in using:

You can use the `?` key in the TUI to view all the key bindings that are available in your context.

Mynav integrates seamlessly with **tmux**, using it to manage sessions efficiently. When a session is created from a workspace, the workspace’s directory path is used as the tmux session name. This design keeps the state transparent and familiar, rather than hidden behind abstraction.

Once inside a tmux session, you can use all your usual tmux features. One key feature that enhances the mynav experience is the ability to **detach from the session** and return to the mynav interface by pressing **`Leader + D`**.

This tight integration gives you the full power of tmux while keeping mynav in sync with your development workflow.

### Navigation

| Key | Action | Context |
| --- | --- | --- |
| `h/←` | Focus left panel | Global |
| `l/→` | Focus right panel | Global |
| `j/↓` | Move down | List views |
| `k/↑` | Move up | List views |
| `Tab` | Toggle focus | Search dialog |
| `Esc` | Close/cancel | Dialogs |

### Actions

| Key | Action | Context |
| --- | --- | --- |
| `Enter` | Open/select item | Global |
| `a` | Create new topic/workspace | Topics/Workspaces view |
| `D` | Delete item | Topics/Workspaces/Sessions view |
| `r` | Rename item | Topics/Workspaces view |
| `X` | Kill session | Workspaces/Sessions view |
| `s` | Search workspaces | Global |
| `?` | Toggle help menu | Global |
| `q` | Quit application | Global |
| `<` | Cycle preview left | Global |
| `>` | Cycle preview right | Global |
| `Ctrl+C` | Quit application | Global |

## ⚙️ Configuration

- MyNav uses a configuration system that supports multiple independent workspaces
- MyNav looks for configuration in the current or any parent directory
- Multiple independent directories can be initialized with MyNav
- Nested configurations are not allowed (invoking mynav nestedly will simply open the parent configuration)
- Home directory cannot be initialized as a MyNav workspace

## 🛠️ Development

Mynav is a straightforward, low-configuration project that only requires the Go runtime to get started in development.

## 🤝 Contributing

Ensure commits use conventional commits.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/GianlucaP106/mynav/blob/main/LICENSE) file for details.

---

[⭐ Star on GitHub](https://github.com/GianlucaP106/mynav/stargazers) • [📫 Report Bug](https://github.com/GianlucaP106/mynav/issues) • [💬 Discussions](https://github.com/GianlucaP106/mynav/discussions)

## Packages

No packages published  

## Languages

- [Go 98.6%](https://github.com/GianlucaP106/mynav/search?l=go)
- [Shell 1.4%](https://github.com/GianlucaP106/mynav/search?l=shell)