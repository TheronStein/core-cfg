#!/bin/bash
tmux display-menu -x W -y S \
    "Install Plugins" i "run-shell '~/.tmux/plugins/tpm/scripts/install_plugins.sh'" \
    "Update Plugins" u "run-shell '~/.tmux/plugins/tpm/scripts/update_plugin.sh'" \
    "Source Plugins" s "run-shell '~/.tmux/plugins/tpm/scripts/source_plugins.sh'" \
    "Clean Plugins" c "run-shell '~/.tmux/plugins/tpm/scripts/clean_plugins.sh'" \
    "List Plugins" l "run-shell '~/.tmux/plugins/tpm/scripts/list_plugins.sh'" \
    "Back" Tab "run-shell '$TMUX_MENUS/main-menu.sh'"
