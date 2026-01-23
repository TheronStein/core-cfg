# Breath-esque Qutebrowser theme by Wakellor957
# Edit however you like ^^

###########################################################################
# 0. WebAuthn / Passkey / FIDO2 Support
###########################################################################
# Note: Passkey support in qutebrowser depends on QtWebEngine (Chromium).
# Hardware security keys (YubiKey, etc.) work for FIDO2/U2F authentication.
# Platform authenticators (fingerprint, Windows Hello) have limited support.
#
# Current limitations (as of qutebrowser 3.6.x):
# - No native passkey management UI
# - FIDO2 User Verification still in development
# - Software authenticators may not work

# Enable experimental web platform features (includes newer WebAuthn APIs)
c.qt.chromium.experimental_web_platform_features = "always"

# Chromium flags for enhanced WebAuthn support
c.qt.args = [
    # Enable WebAuthn for remote desktop scenarios (if using RDP/VNC)
    "webauthn-remote-desktop-support",
    # Allow enterprise attestation for corporate passkeys
    "enable-features=WebAuthenticationEnterpriseAttestation",
]

###########################################################################
# 1. Ad-blocker (uBlock Origin level, built-in, fast & private)
###########################################################################
c.content.blocking.enabled = True
c.content.blocking.method = "both"  # hosts-based + adblock syntax
c.content.blocking.hosts.block_subdomains = True

# Best maintained lists in 2025
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://easylist.to/easylist/fanboy-social.txt",
    "https://secure.fanboy.co.nz/fanboy-annoyance.txt",
    "https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/resource-abuse.txt",
    "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext",
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts",
]

config.bind(
    "ua", "adblock-update"
)  # Optional: Bind 'xu' to manually update adblock lists

# Auto-update lists once per week
# c.content.blocking.adblock.update_interval = 604800  # 7 days
# Use the adblock method (requires python-adblock)
c.content.blocking.method = "adblock"

# Or use both hosts and adblock for maximum coverage
# c.content.blocking.method = 'both'

###########################################################################
# 2. Bitwarden integration via official qute-bitwarden userscript
###########################################################################
# Make sure the script exists:
# ~/.local/share/qutebrowser/userscripts/qute-bitwarden
# (download with wget as shown in my previous message)

config.bind("<Ctrl+b>", "spawn --userscript qute-bitwarden")  # auto-fill
config.bind("<Ctrl+B>", "spawn --userscript qute-bitwarden -d")  # dmenu/rofi selector


###########################################################################
# 3. Permissions needed for devtools, qute:// pages and the Bitwarden script
###########################################################################
# Load images and enable JS on internal pages
c.content.images = True
c.content.javascript.enabled = True

config.set("content.images", True, "chrome-devtools://*")
config.set("content.images", True, "devtools://*")
config.set("content.javascript.enabled", True, "chrome-devtools://*")
config.set("content.javascript.enabled", True, "devtools://*")
config.set("content.javascript.enabled", True, "chrome://*/*")
# Hide JS console messages (error, warning, info, none)
c.content.javascript.log_message.excludes = {
    "error": ["*TrustedHTML*", "*trusted-types*"],
}
config.set("content.javascript.enabled", True, "qute://*/*")
# c.content.javascript.log['error'] = 'none'
# Allow the qute-bitwarden userscript to phone home to vault.bitwarden.com or your self-hosted instance
config.set(
    "content.local_content_can_access_remote_urls",
    True,
    "file:///home/theron/.local/share/qutebrowser/userscripts/*",
)

# Optional: keep this False for security (the script doesn’t need local file access)
config.set(
    "content.local_content_can_access_file_urls",
    False,
    "file:///home/theron/.local/share/qutebrowser/userscripts/*",
)
