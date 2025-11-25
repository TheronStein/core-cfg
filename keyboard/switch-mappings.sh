#!/bin/bash
if [[ "$1" == "custom" ]]; then
  sudo ln -sf $HOME/.core/.proj/keyconf/custom.conf /etc/keyd/default.conf
elif [[ "$1" == "default" ]]; then
  sudo ln -sf $HOME/.core/.proj/keyconf/default.conf /etc/keyd/default.conf
else
  echo "Usage: $0 {custom|default}"
  exit 1
fi
sudo systemctl restart keyd
echo "Switched to $1 keyd config"
