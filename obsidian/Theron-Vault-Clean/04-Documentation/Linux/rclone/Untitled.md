rclone /home/theron/.config/rclone/rclone.conf --vfs-cache-mode writes mount onedrive: /hdd/theron &

sudo rclone --config /theron/your-username/.config/rclone/rclone.conf --vfs-cache-mode writes mount onedrive: /hdd/theron &


88f4acd5-d705-4b29-854b-53e6335e64b0

sudo systemctl status ssh
sudo systemctl restart ssh

sudo tcpdump -i enp1s0f0 broadcast

sudo ifconfig eth0 down

Still unable to connect, could you run this command for me? I think I might have 
sudo ifconfig eth0

Displays statistics for the following properties:
LightStats	RenderStats	RenderTimes	SectorHacks
MissingTextures	Sound	Music	SkyBoxes
Interpolations	Blit	Sight	Spawns
Think	GC	ScanCycles	WallCycles
FPS	NetTraffic	Bots	Pathing

Install WinFsp and rclone Mount:

Install WinFsp from here.
Use rclone mount to mount your cloud storage as a network drive.
For example, to mount Google Drive:
sh
Copy code
rclone mount remote: X: --vfs-cache-mode writes
Replace remote with the name of your configured remote and X: with your desired drive letter.

Integrate with RaiDrive or Mountain Duck:

Use RaiDrive or Mountain Duck to map the rclone-mounted drives and enable sync status icons.
Install RaiDrive or Mountain Duck and set it up to mount the cloud storage configured in rclone.
Selective Sync