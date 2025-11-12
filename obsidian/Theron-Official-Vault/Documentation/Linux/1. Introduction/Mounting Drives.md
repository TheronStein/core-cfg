To mount the drive `/dev/sda1` and verify that it is mounted properly, follow these steps:

### Mount the Drive

1. **Mount the drive:**
   ```sh
   sudo mount /dev/sda1 /hdd
   
   sudo mount --bind /hdd/usr/theron/ /home/theron
   ```

2. **Verify the mount:**
   ```sh
   mount | grep /hdd
   ```

   This command will list the currently mounted filesystems and should show an entry for `/dev/sda1` mounted at `/hdd`.

### Verify the Mount

1. **Check the filesystem:**
   ```sh
   df -h | grep /hdd
   ```

   This will show the disk usage for the mounted filesystem. You should see an entry for `/dev/sda1` mounted on `/hdd` with its corresponding disk usage information.

2. **List the contents of the mount point:**
   ```sh
   ls -la /hdd
   ```

   This will show the contents of the `/hdd` directory. If the mount was successful, you should see the files and directories on the `/dev/sda1` partition.

### Example Commands and Output

```sh
sudo mount /dev/sda1 /hdd
```

```sh
mount | grep /hdd
```

Expected output:
```plaintext
/dev/sda1 on /hdd type ext4 (rw,relatime,data=ordered)
```

```sh
df -h | grep /hdd
```

Expected output:
```plaintext
/dev/sda1        50G   5.0G   45G  10% /hdd
```

```sh
ls -la /hdd
```

Expected output (contents may vary):
```plaintext
total 24
drwxr-xr-x  3 root root  4096 Aug  7 10:00 .
drwxr-xr-x 22 root root  4096 Aug  7 10:00 ..
-rw-r--r--  1 root root     0 Aug  7 10:00 examplefile
```

### Adding to `/etc/fstab`

Since you've already added the line to your `/etc/fstab` file, this should mount the filesystem automatically on boot. However, if you want to mount it now without rebooting, you can use:

```sh
sudo mount -a
```

This command will mount all filesystems mentioned in `/etc/fstab` that are not currently mounted.

By following these steps, you should be able to mount the drive `/dev/sda1` and verify that it is mounted correctly.