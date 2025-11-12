[package]
name = "VirtualDesktops"
version = "0.1.0"
edition = "2021"

[dependencies]
# Windows-specific functionality for desktop and window management
winvd = "0.0.46"
windows = { version = "0.44.0", features = ["Win32_Foundation", "Win32_UI_WindowsAndMessaging"] }

# Asynchronous runtime, useful if you decide to integrate async operations
tokio = { version = "1", features = ["full"] }
async-std = "1.11.0"

# For cross-thread communication and handling
crossbeam = "0.8.1"

# For managing global/static data easily
lazy_static = "1.4.0"

# Logging utilities
log = "0.4.14"
pretty_env_logger = "0.4.0"

# Device query for keyboard input
device_query = "2.1.0"

[profile.dev]
panic = "unwind"

[profile.release]
panic = "unwind"
