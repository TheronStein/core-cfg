import os

import subprocess

import time

import signal

import sys

  

# Configuration

CLOUD_LIST = ["onedrive", "dropbox", "mega", "google"]
CLOUD_STRING = "OneDrive", "Dropbox", "Mega", "Google Drive"]
SEL_CLOUD = 0
MOUNT_DIR = os.path.expanduser("~/{CLOUD_LIST[SEL_CLOUD][]}")      # Mount directiory

SYNC_INTERVAL = 1300              # Check every half hour


def create_mount_dir():

    if not os.path.isdir(MOUNT_DIR):

        print(f"Creating mount directory: {MOUNT_DIR}")

        os.makedirs(MOUNT_DIR)

def mount_drive:

    print("Mounting OneDrive...")

    global mount_process

    mount_process = subprocess.Popen(["rclone", "mount", f"{REMOTE_NAME}:", MOUNT_DIR, "--vfs-cache-mode", "writes"])

    print(f"OneDrive mounted to {MOUNT_DIR} with PID {mount_process.pid}")


[import os import subprocess import time import signal import sys # Configuration REMOTE_NAME = "onedrive" # The name of your rclone remote MOUNT_DIR = os.path.expanduser("~/OneDrive") # The local directory to mount OneDrive LOCAL_SYNC_DIR = os.path.expanduser("~/LocalSync") # The local directory to sync with OneDrive SYNC_INTERVAL = 3600 # Sync interval in seconds (e.g., 3600 seconds = 1 hour) # Function to check if the mount directory exists, if not, create it def create_mount_dir(): if not os.path.isdir(MOUNT_DIR): print(f"Creating mount directory: {MOUNT_DIR}") os.makedirs(MOUNT_DIR) # Function to mount OneDrive def mount_onedrive(): print("Mounting OneDrive...") global mount_process mount_process = subprocess.Popen(["rclone", "mount", f"{REMOTE_NAME}:", MOUNT_DIR, "--vfs-cache-mode", "writes"]) print(f"OneDrive mounted to {MOUNT_DIR} with PID {mount_process.pid}") # Function to sync local directory with OneDrive def sync_onedrive(): print("Syncing local directory with OneDrive...") subprocess.run(["rclone", "sync", LOCAL_SYNC_DIR, f"{REMOTE_NAME}:/path/to/onedrive/folder"]) print("Sync complete.") # Function to unmount OneDrive def unmount_onedrive(): print("Unmounting OneDrive...") subprocess.run(["fusermount", "-u", MOUNT_DIR]) print("OneDrive unmounted.") # Signal handler to unmount on exit def signal_handler(sig, frame): unmount_onedrive() sys.exit(0) if __name__ == "__main__": signal.signal(signal.SIGINT, signal_handler) signal.signal(signal.SIGTERM, signal_handler) create_mount_dir() mount_onedrive() try: while True: sync_onedrive() time.sleep(SYNC_INTERVAL) except Exception as e: print(f"An error occurred: {e}") unmount_onedrive()](<import os
import subprocess
import time
import signal
import sys

# Configuration
REMOTE_NAME = "onedrive"          # The name of your rclone remote
MOUNT_DIR = os.path.expanduser("~/OneDrive")      # The local directory to mount OneDrive
LOCAL_SYNC_DIR = os.path.expanduser("~/LocalSync") # The local directory to sync with OneDrive
SYNC_INTERVAL = 3600              # Sync interval in seconds (e.g., 3600 seconds = 1 hour)

# Function to check if the mount directory exists, if not, create it
def create_mount_dir():
    if not os.path.isdir(MOUNT_DIR):
        print(f"Creating mount directory: {MOUNT_DIR}")
        os.makedirs(MOUNT_DIR)

# Function to mount OneDrive
def mount_onedrive():
    print("Mounting OneDrive...")
    global mount_process
    mount_process = subprocess.Popen(["rclone", "mount", f"{REMOTE_NAME}:", MOUNT_DIR, "--vfs-cache-mode", "writes"])
    print(f"OneDrive mounted to {MOUNT_DIR} with PID {mount_process.pid}")

# Function to sync local directory with OneDrive
def sync_onedrive():
    print("Syncing local directory with OneDrive...")
    subprocess.run(["rclone", "sync", LOCAL_SYNC_DIR, f"{REMOTE_NAME}:/path/to/onedrive/folder"])
    print("Sync complete.")

# Function to unmount OneDrive
def unmount_onedrive():
    print("Unmounting OneDrive...")
    subprocess.run(["fusermount", "-u", MOUNT_DIR])
    print("OneDrive unmounted.")

# Signal handler to unmount on exit
def signal_handler(sig, frame):
    unmount_onedrive()
    sys.exit(0)

if __name__ == "__main__":
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
        unmount_onedrive()>)