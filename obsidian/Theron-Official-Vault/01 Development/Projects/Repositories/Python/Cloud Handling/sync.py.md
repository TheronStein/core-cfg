Def sync_onedrive ():

    print("Syncing local directory with OneDrive...")

    subprocess.run(["rclone", "sync", LOCAL_SYNC_DIR, f"{REMOTE_NAME}:/path/to/onedrive/folder"])

    print("Sync complete.")


Def unmount_onedrive ():

    print("Unmounting OneDrive...")

    subprocess.run(["fusermount", "-u", MOUNT_DIR])

    print("OneDrive unmounted.")
    
Def signal_handler (sig, frame):

    unmount_onedrive()

    sys.exit(0)

If __name__ == "__main__":

    signal.signal(signal.SIGINT, signal_handler)

    signal.signal(signal.SIGTERM, signal_handler)

    create_mount_dir()

    mount_onedrive()

    try:

        while True:

            sync_onedrive()

            time.sleep(SYNC_INTERVAL)

    except Exception as e:

        print(f"An error occurred: {e}")

        unmount_onedrive()