[Unit]
Description=Linux Multi-User Editor
After=network-online.target

[Service]
ExecStart=/usr/src/UnrealEngine/Engine/Binaries/Linux/UnrealMultiUserServer-Linux-Debug
WorkingDirectory=/usr/src/UnrealEngine


Environment=NODE_ENV=production
Restart=always
RestartSec=10

ExecStart=/var/www/rampage/ ./server.mjs
WorkingDirectory=/var/www/rampage/

[Service]
User=theron
Group=theron
Environment="templdpath=$LD_LIBRARY_PATH"
Environment="LD_LIBRARY_PATH=/home/steam/:$LD_LIBRARY_PATH"
ExecStart=/usr/src/UnrealEngine/Engine/Binaries/Linux/UnrealMultiUserServer-Linux-Debug
Restart=always
RuntimeMaxSec=4h
LimitCORE=0


[Install]
WantedBy=multi-user.target

Environment=NODE_ENV=production


[Unit]
Description=Linux Multi-User Editor
After=network-online.target

[Service]
User=theron
Group=theron
WorkingDirectory=/usr/src/UnrealEngine
ExecStart=/usr/src/UnrealEngine/Engine/Binaries/Linux/UnrealMultiUserServer-Linux-Debug

[Install]
WantedBy=multi-user.target

