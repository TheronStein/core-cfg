#!/bin/sh

PROGRESS_CURR=0
PROGRESS_TOTAL=798                         

# This file was autowritten by rmlint
# rmlint was executed from: $CORE_CFG/yazi/
# Your command line was: rmlint /home/theron/mnt/cachyos/Dropbox/Archives -T df -g

RMLINT_BINARY="/usr/bin/rmlint"

# Only use sudo if we're not root yet:
# (See: https://github.com/sahib/rmlint/issues/27://github.com/sahib/rmlint/issues/271)
SUDO_COMMAND="sudo"
if [ "$(id -u)" -eq "0" ]
then
  SUDO_COMMAND=""
fi

USER='theron'
GROUP='theron'

# Set to true on -n
DO_DRY_RUN=

# Set to true on -p
DO_PARANOID_CHECK=

# Set to true on -r
DO_CLONE_READONLY=

# Set to true on -q
DO_SHOW_PROGRESS=true

# Set to true on -c
DO_DELETE_EMPTY_DIRS=

# Set to true on -k
DO_KEEP_DIR_TIMESTAMPS=

# Set to true on -i
DO_ASK_BEFORE_DELETE=

# Tempfiles for saving timestamps
STAMPFILE=
STAMPFILE2=

##################################
# GENERAL LINT HANDLER FUNCTIONS #
##################################

COL_RED='[0;31m'
COL_BLUE='[1;34m'
COL_GREEN='[0;32m'
COL_YELLOW='[0;33m'
COL_RESET='[0m'

exit_cleanup() {
    trap - INT TERM EXIT
    if [ -n "$STAMPFILE" ]; then
        rm -f -- "$STAMPFILE"
    fi
    if [ -n "$STAMPFILE2" ]; then
        rm -f -- "$STAMPFILE2"
    fi
}

trap exit_cleanup EXIT
trap exit INT TERM

print_progress_prefix() {
    if [ -n "$DO_SHOW_PROGRESS" ]; then
        PROGRESS_PERC=0
        if [ $((PROGRESS_TOTAL)) -gt 0 ]; then
            PROGRESS_PERC=$((PROGRESS_CURR * 100 / PROGRESS_TOTAL))
        fi
        printf '%s[%3d%%]%s ' "${COL_BLUE}" "$PROGRESS_PERC" "${COL_RESET}"
        if [ $# -eq "1" ]; then
            PROGRESS_CURR=$((PROGRESS_CURR+$1))
        else
            PROGRESS_CURR=$((PROGRESS_CURR+1))
        fi
    fi
}

handle_emptyfile() {
    print_progress_prefix
    echo "${COL_GREEN}Deleting empty file:${COL_RESET} $1"
    if [ -z "$DO_DRY_RUN" ]; then
        rm -f "$1"
    fi
}

handle_emptydir() {
    print_progress_prefix
    echo "${COL_GREEN}Deleting empty directory: ${COL_RESET}$1"
    if [ -z "$DO_DRY_RUN" ]; then
        rmdir "$1"
    fi
}

handle_bad_symlink() {
    print_progress_prefix
    echo "${COL_GREEN} Deleting symlink pointing nowhere: ${COL_RESET}$1"
    if [ -z "$DO_DRY_RUN" ]; then
        rm -f "$1"
    fi
}

handle_unstripped_binary() {
    print_progress_prefix
    echo "${COL_GREEN} Stripping debug symbols of: ${COL_RESET}$1"
    if [ -z "$DO_DRY_RUN" ]; then
        strip -s "$1"
    fi
}

handle_bad_user_id() {
    print_progress_prefix
    echo "${COL_GREEN}chown ${USER}${COL_RESET} $1"
    if [ -z "$DO_DRY_RUN" ]; then
        chown "$USER" "$1"
    fi
}

handle_bad_group_id() {
    print_progress_prefix
    echo "${COL_GREEN}chgrp ${GROUP}${COL_RESET} $1"
    if [ -z "$DO_DRY_RUN" ]; then
        chgrp "$GROUP" "$1"
    fi
}

handle_bad_user_and_group_id() {
    print_progress_prefix
    echo "${COL_GREEN}chown ${USER}:${GROUP}${COL_RESET} $1"
    if [ -z "$DO_DRY_RUN" ]; then
        chown "$USER:$GROUP" "$1"
    fi
}

###############################
# DUPLICATE HANDLER FUNCTIONS #
###############################

check_for_equality() {
    if [ -f "$1" ]; then
        # Use the more lightweight builtin `cmp` for regular files:
        cmp -s "$1" "$2"
    else
        # Fallback to `rmlint --equal` for directories:
        "$RMLINT_BINARY" -p --equal  "$1" "$2"
    fi
}

original_check() {
    if [ ! -e "$2" ]; then
        echo "${COL_RED}^^^^^^ Error: original has disappeared - cancelling.....${COL_RESET}"
        return 1
    fi

    if [ ! -e "$1" ]; then
        echo "${COL_RED}^^^^^^ Error: duplicate has disappeared - cancelling.....${COL_RESET}"
        return 1
    fi

    # Check they are not the exact same file (hardlinks allowed):
    if [ "$1" = "$2" ]; then
        echo "${COL_RED}^^^^^^ Error: original and duplicate point to the *same* path - cancelling.....${COL_RESET}"
        return 1
    fi

    # Do double-check if requested:
    if [ -z "$DO_PARANOID_CHECK" ]; then
        return 0
    else
        # Check latest result.
        if ! check_for_equality "$1" "$2"; then
            echo "${COL_RED}^^^^^^ Error: files no longer identical - cancelling.....${COL_RESET}"
            return 1
        fi
    fi
}

cp_symlink() {
    print_progress_prefix
    echo "${COL_YELLOW}Symlinking to original: ${COL_RESET}$1"
    if original_check "$1" "$2"; then
        if [ -z "$DO_DRY_RUN" ]; then
            # replace duplicate with symlink
            rm -rf "$1"
            ln -s "$2" "$1"
            # make the symlink's mtime the same as the original
            touch -mr "$2" -h "$1"
        fi
    fi
}

cp_hardlink() {
    if [ -d "$1" ]; then
        # for duplicate dir's, can't hardlink so use symlink
        cp_symlink "$@"
        return $?
    fi
    print_progress_prefix
    echo "${COL_YELLOW}Hardlinking to original: ${COL_RESET}$1"
    if original_check "$1" "$2"; then
        if [ -z "$DO_DRY_RUN" ]; then
            # replace duplicate with hardlink
            rm -rf "$1"
            ln "$2" "$1"
        fi
    fi
}

cp_reflink() {
    if [ -d "$1" ]; then
        # for duplicate dir's, can't clone so use symlink
        cp_symlink "$@"
        return $?
    fi
    print_progress_prefix
    # reflink $1 to $2's data, preserving $1's  mtime
    echo "${COL_YELLOW}Reflinking to original: ${COL_RESET}$1"
    if original_check "$1" "$2"; then
        if [ -z "$DO_DRY_RUN" ]; then
            if [ -z "$STAMPFILE2" ]; then
                STAMPFILE2=$(mktemp "${TMPDIR:-/tmp}/rmlint.XXXXXXXX.stamp")
            fi
            touch -mr "$1" -- "$STAMPFILE2"
            if [ -d "$1" ]; then
                rm -rf "$1"
            fi
            cp --archive --reflink=always -- "$2" "$1"
            touch -mr "$STAMPFILE2" -- "$1"
        fi
    fi
}

clone() {
    print_progress_prefix
    # clone $1 from $2's data
    # note: no original_check() call because rmlint --dedupe takes care of this
    echo "${COL_YELLOW}Cloning to: ${COL_RESET}$1"
    if [ -z "$DO_DRY_RUN" ]; then
        if [ -n "$DO_CLONE_READONLY" ]; then
            $SUDO_COMMAND "$RMLINT_BINARY" --dedupe  --dedupe-readonly "$2" "$1"
        else
            "$RMLINT_BINARY" --dedupe  "$2" "$1"
        fi
    fi
}

skip_hardlink() {
    print_progress_prefix
    echo "${COL_BLUE}Leaving as-is (already hardlinked to original): ${COL_RESET}$1"
}

skip_reflink() {
    print_progress_prefix
    echo "${COL_BLUE}Leaving as-is (already reflinked to original): ${COL_RESET}$1"
}

user_command() {
    print_progress_prefix

    echo "${COL_YELLOW}Executing user command: ${COL_RESET}$1"
    if [ -z "$DO_DRY_RUN" ]; then
        # You can define this function to do what you want:
        echo 'no user command defined.'
    fi
}

remove_cmd() {
    print_progress_prefix
    echo "${COL_YELLOW}Deleting: ${COL_RESET}$1"
    if original_check "$1" "$2"; then
        if [ -z "$DO_DRY_RUN" ]; then
            if [ -n "$DO_KEEP_DIR_TIMESTAMPS" ]; then
                touch -r "$(dirname "$1")" "$STAMPFILE"
            fi
            if [ -n "$DO_ASK_BEFORE_DELETE" ]; then
              rm -ri "$1"
            else
              rm -rf "$1"
            fi
            if [ -n "$DO_KEEP_DIR_TIMESTAMPS" ]; then
                # Swap back old directory timestamp:
                touch -r "$STAMPFILE" -- "$(dirname "$1")"
            fi

            if [ -n "$DO_DELETE_EMPTY_DIRS" ]; then
                DIR=$(dirname "$1")
                while [ ! "$(ls -A "$DIR")" ]; do
                    print_progress_prefix 0
                    echo "${COL_GREEN}Deleting resulting empty dir: ${COL_RESET}$DIR"
                    rmdir "$DIR"
                    DIR=$(dirname "$DIR")
                done
            fi
        fi
    fi
}

original_cmd() {
    print_progress_prefix
    echo "${COL_GREEN}Keeping:  ${COL_RESET}$1"
}

##################
# OPTION PARSING #
##################

ask() {
    cat << EOF

This script will delete certain files rmlint found.
It is highly advisable to view the script first!

Rmlint was executed in the following way:

   $ rmlint /home/theron/mnt/cachyos/Dropbox/Archives -T df -g

Execute this script with -d to disable this informational message.
Type any string to continue; CTRL-C, Enter or CTRL-D to abort immediately
EOF
    read -r eof_check
    if [ -z "$eof_check" ]
    then
        # Count Ctrl-D and Enter as aborted too.
        echo "${COL_RED}Aborted on behalf of the user.${COL_RESET}"
        exit 1;
    fi
}

usage() {
    cat << EOF
usage: $0 OPTIONS

OPTIONS:

  -h   Show this message.
  -d   Do not ask before running.
  -x   Keep rmlint.sh; do not autodelete it.
  -p   Recheck that files are still identical before removing duplicates.
  -r   Allow deduplication of files on read-only btrfs snapshots. (requires sudo)
  -n   Do not perform any modifications, just print what would be done. (implies -d and -x)
  -c   Clean up empty directories while deleting duplicates.
  -q   Do not show progress.
  -k   Keep the timestamp of directories when removing duplicates.
  -i   Ask before deleting each file
EOF
}

DO_REMOVE=
DO_ASK=

while getopts "dhxnrpqcki" OPTION
do
  case $OPTION in
     h)
       usage
       exit 0
       ;;
     d)
       DO_ASK=false
       ;;
     x)
       DO_REMOVE=false
       ;;
     n)
       DO_DRY_RUN=true
       DO_REMOVE=false
       DO_ASK=false
       DO_ASK_BEFORE_DELETE=false
       ;;
     r)
       DO_CLONE_READONLY=true
       ;;
     p)
       DO_PARANOID_CHECK=true
       ;;
     c)
       DO_DELETE_EMPTY_DIRS=true
       ;;
     q)
       DO_SHOW_PROGRESS=
       ;;
     k)
       DO_KEEP_DIR_TIMESTAMPS=true
       ;;
     i)
       DO_ASK_BEFORE_DELETE=true
       ;;
     *)
       usage
       exit 1
  esac
done

if [ -z $DO_REMOVE ]
then
    echo "#${COL_YELLOW} ///${COL_RESET}This script will be deleted after it runs${COL_YELLOW}///${COL_RESET}"
fi

if [ -z $DO_ASK ]
then
  usage
  ask
fi

if [ -n "$DO_DRY_RUN" ]
then
    echo "#${COL_YELLOW} ////////////////////////////////////////////////////////////${COL_RESET}"
    echo "#${COL_YELLOW} /// ${COL_RESET} This is only a dry run; nothing will be modified! ${COL_YELLOW}///${COL_RESET}"
    echo "#${COL_YELLOW} ////////////////////////////////////////////////////////////${COL_RESET}"
elif [ -n "$DO_KEEP_DIR_TIMESTAMPS" ]; then
    STAMPFILE=$(mktemp "${TMPDIR:-/tmp}/rmlint.XXXXXXXX.stamp")
fi

######### START OF AUTOGENERATED OUTPUT #########


original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/Compat.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/Game.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Game.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/Hardware.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Hardware.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/Input.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Input.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Lightmass.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/Lightmass.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Scalability.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/Scalability.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/DeviceProfiles.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/DeviceProfiles.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/MagicLeap.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/MagicLeap.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/MagicLeapLightEstimation.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/MagicLeapLightEstimation.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/MotoSynth.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/MotoSynth.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Niagara.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/Niagara.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/OculusVR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/OculusVR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Paper2D.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/Paper2D.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/PhysXVehicles.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/PhysXVehicles.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/PostSplashScreen.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/PostSplashScreen.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/RuntimeOptions.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/RuntimeOptions.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/Synthesis.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Synthesis.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/VariantManagerContent.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/VariantManagerContent.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/Compat.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/ControlRig.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/DeviceProfiles.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/EditorScriptingUtilities.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/FullBodyIK.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/Game.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/HairStrands.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/Hardware.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/Input.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/Lightmass.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/Niagara.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/Paper2D.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/RuntimeOptions.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/Scalability.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/Synthesis.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/TraceDataFilters.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/VariantManagerContent.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/Compat.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/ControlRig.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/DeviceProfiles.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/EditorScriptingUtilities.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/FullBodyIK.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/Game.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/HairStrands.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/Hardware.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/Input.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/Lightmass.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/Niagara.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/Paper2D.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/RuntimeOptions.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/Scalability.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/Synthesis.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/TraceDataFilters.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/VariantManagerContent.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/Bridge.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/Compat.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/ControlRig.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/DatasmithContent.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/DeviceProfiles.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/EditorScriptingUtilities.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/EnhancedInput.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/FullBodyIK.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/GLTFExporter.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/Hardware.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/IKRig.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/Input.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/InstallBundle.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/Interchange.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/Lightmass.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/Metasound.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/Niagara.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/Paper2D.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/RuntimeOptions.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/Scalability.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/Synthesis.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/TraceDataFilters.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/TraceUtilities.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/WindowsEditor/VariantManagerContent.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Compat.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DB Browser for SQLite/translations/qt_en.qm' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DB Browser for SQLite/translations/qtbase_en.qm' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DB Browser for SQLite/translations/qt_en.qm' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DB Browser for SQLite/translations/qtmultimedia_en.qm' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DB Browser for SQLite/translations/qt_en.qm' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DB Browser for SQLite/translations/qtscript_en.qm' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DB Browser for SQLite/translations/qt_en.qm' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DB Browser for SQLite/translations/qtxmlpatterns_en.qm' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DB Browser for SQLite/translations/qt_en.qm' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/enc-amf/locale/oc-FR.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-x264/locale/oc-FR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/enc-amf/locale/oc-FR.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-qsv11/locale/oc-FR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/enc-amf/locale/oc-FR.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-ffmpeg/locale/oc-FR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/enc-amf/locale/oc-FR.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/en-GB.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/en-GB.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/en-GB.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/oc-FR.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/oc-FR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/oc-FR.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/99c94f9d.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/a64a0a78.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/a64a0a78.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/089bc3de.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/089bc3de.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/09b713d3.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/09b713d3.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/11b06015.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/11b06015.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/1f683343.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/1f683343.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/218409f6.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/218409f6.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/2657c409.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/2657c409.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/2ad2a7fd.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/2ad2a7fd.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/50a675f9.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/50a675f9.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/52ed2538.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/52ed2538.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/58fb7916.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/58fb7916.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/6bead350.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/6bead350.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/7b241018.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/7b241018.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/866581fd.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/866581fd.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/8c0e1344.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/8c0e1344.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/8e9331e2.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/8e9331e2.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/9c1a1723.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/9c1a1723.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/a02d411d.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/a02d411d.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/cc8b2eeb.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/cc8b2eeb.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/d63b3057.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/d63b3057.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/d859983c.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/d859983c.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/db6fd95f.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/db6fd95f.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/AssetRegistryCache/f0d5030c.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/f0d5030c.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/AssetRegistryCache/99c94f9d.bin' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/Editor.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/Editor.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/Editor.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/UnrealInsightsSettings.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/UnrealInsightsSettings.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/UnrealInsightsSettings.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/Config/CoalescedSourceConfigs/GameUserSettings.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/Config/CoalescedSourceConfigs/GameUserSettings.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/Config/CoalescedSourceConfigs/GameUserSettings.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Intermediate/Config/CoalescedSourceConfigs/GameUserSettings.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/Config/CoalescedSourceConfigs/GameUserSettings.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Intermediate/Config/CoalescedSourceConfigs/GameUserSettings.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/Config/CoalescedSourceConfigs/GameUserSettings.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Intermediate/Config/CoalescedSourceConfigs/GameUserSettings.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/Config/CoalescedSourceConfigs/GameUserSettings.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Config/DefaultEditorPerProjectUserSettings.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Config/DefaultEditorPerProjectUserSettings.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Config/DefaultEditorPerProjectUserSettings.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Config/DefaultEditorPerProjectUserSettings.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Config/DefaultEditorPerProjectUserSettings.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Config/DefaultEditorPerProjectUserSettings.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Config/DefaultEditorPerProjectUserSettings.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Config/DefaultEditorPerProjectUserSettings.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Config/DefaultEditorPerProjectUserSettings.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Evidence.uproject' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Evidence.uproject' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Evidence.uproject' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Evidence.uproject' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Evidence.uproject' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Evidence.uproject' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/PackageRestoreData.json' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/PackageRestoreData.json' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/PackageRestoreData.json' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Autosaves/PackageRestoreData.json' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/PackageRestoreData.json' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Autosaves/PackageRestoreData.json' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/PackageRestoreData.json' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Autosaves/PackageRestoreData.json' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/PackageRestoreData.json' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Acri/sizegrip.png' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Rachni/sizegrip.png' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Acri/sizegrip.png' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/CrashReportClient/UE4CC-Windows-D5EC79424D711AE78C00B18A0E83E4CF/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/CrashReportClient/UE4CC-Windows-D5EC79424D711AE78C00B18A0E83E4CF/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/CrashReportClient/UE4CC-Windows-2987D8B04902D8A7CFC73DA442AF9445/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/CrashReportClient/UE4CC-Windows-2987D8B04902D8A7CFC73DA442AF9445/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/CrashReportClient/UE4CC-Windows-2D99AC9D413CB74A9AFF0F942BE50E52/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/CrashReportClient/UE4CC-Windows-2D99AC9D413CB74A9AFF0F942BE50E52/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/CrashReportClient/UECC-Windows-96C5E3A6455AECF4334DC1824206E20A/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Crashes/UECC-Windows-96C5E3A6455AECF4334DC1824206E20A_0000/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/CrashReportClient/UECC-Windows-221C05A14CB5C8CF901E2488AAAA8C3A/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Crashes/UECC-Windows-221C05A14CB5C8CF901E2488AAAA8C3A_0000/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/CrashReportClient/UECC-Windows-815255CB4FDB526A2316F4BB7B85153D/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/CrashReportClient/UECC-Windows-424D70344CA204523EE72BAC47623E36/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/CrashReportClient/UECC-Windows-ED26695E4AF3FF0113E2BA9121196994/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/CrashReportClient/UECC-Windows-010CC13944CFA724B5003D991B320477/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/CrashReportClient/UECC-Windows-2B2A65ED49C8C7ABAC44E79EC277DAE2/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/CrashReportClient/UECC-Windows-6676A5B746A0CEB634A70F955F89AC69/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/CrashReportClient/UECC-Windows-5C8A46C7465869D459E62BB6882DBAC7/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/CrashReportClient/UECC-Windows-7455041A4D22320767CFEE85A834CDCA/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Crashes/UECC-Windows-7455041A4D22320767CFEE85A834CDCA_0000/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/CrashReportClient/UECC-Windows-297681E24216684982833CA6E40D85F4/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Saved/Config/CrashReportClient/UECC-Windows-034A913F410DDC23D4C318BAF37EACBC/CrashReportClient.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashReportClient.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ba-RU.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ba-RU.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ba-RU.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Config/DefaultGame.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Config/DefaultGame.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Config/DefaultGame.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Config/DefaultGame.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Config/DefaultGame.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Config/DefaultGame.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Config/DefaultGame.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Rachni/checkbox_checked.png' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Rachni/checkbox_checked_focus.png' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Rachni/checkbox_checked.png' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/win-wasapi/locale/hr-HR.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/win-wasapi/locale/sr-CS.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/win-wasapi/locale/hr-HR.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Github Repos/Rampage-Stats/Rampage-Stats/Decorate/Check.dec' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Github Repos/Rampage-Stats/Rampage-Stats/src/Decorate/Check.dec' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Github Repos/Rampage-Stats/Rampage-Stats/Decorate/Check.dec' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OpenRCT2-0.4.2-windows-portable-x64/data/shaders/applypalette.vert' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OpenRCT2-0.4.2-windows-portable-x64/data/shaders/applytransparency.vert' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OpenRCT2-0.4.2-windows-portable-x64/data/shaders/applypalette.vert' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/nn-NO.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/nn-NO.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/nn-NO.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/ReimportCache/3688439234.bin' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/ReimportCache/3688439234.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/ReimportCache/3688439234.bin' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Intermediate/ReimportCache/3688439234.bin' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Intermediate/ReimportCache/3688439234.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Intermediate/ReimportCache/3688439234.bin' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Config/DefaultEditor.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Config/DefaultEditor.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Config/DefaultEditor.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Config/DefaultEditor.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Config/DefaultEditor.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Config/DefaultEditor.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Config/DefaultEditor.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/kab-KAB.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/kab-KAB.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/kab-KAB.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/sr-CS.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/sr-CS.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/sr-CS.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/az-AZ.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/az-AZ.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/az-AZ.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/mn-MN.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/mn-MN.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/mn-MN.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Light/media-pause.svg' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Light/media/media_pause.svg' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Light/media-pause.svg' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Dark/media-pause.svg' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Dark/media/media_pause.svg' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Dark/media-pause.svg' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Dark/sources/media.svg' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Dark/media/media_play.svg' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Dark/sources/media.svg' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Light/sources/media.svg' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Light/media/media_play.svg' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Light/sources/media.svg' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/sr-SP.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/sr-SP.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/sr-SP.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/hr-HR.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/hr-HR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/hr-HR.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/eo-UY.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/eo-UY.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/eo-UY.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/WorldState/2733464406.json' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/WorldState/2733464406.json' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/WorldState/2733464406.json' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/convenience_tools/convert.cmd' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/helpers/cheahjs-save-tools/convert.cmd' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/convenience_tools/convert.cmd' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/GameUserSettings.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Config/WindowsEditor/GameUserSettings.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Config/WindowsEditor/GameUserSettings.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/GameUserSettings.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/GameUserSettings.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/GameUserSettings.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-text/locale/hr-HR.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-text/locale/sr-CS.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-text/locale/hr-HR.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/szl-PL.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/szl-PL.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/szl-PL.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/LICENSE' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/helpers/cheahjs-save-tools/LICENSE' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/LICENSE' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ta-IN.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ta-IN.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ta-IN.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Dark/mute.svg' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Light/mute.svg' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-studio/themes/Dark/mute.svg' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/et-EE.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/et-EE.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/et-EE.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Geometry/Meshes/1M_Cube.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Geometry/Meshes/1M_Cube.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Geometry/Meshes/1M_Cube.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Geometry/Meshes/1M_Cube.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Geometry/Meshes/1M_Cube.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Geometry/Meshes/1M_Cube.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Geometry/Meshes/1M_Cube.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/nb-NO.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/nb-NO.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/nb-NO.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/si-LK.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/si-LK.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/si-LK.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/rtmp-services/schema/package-schema.json' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/win-capture/schema/package-schema.json' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/rtmp-services/schema/package-schema.json' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/4.0/Browsers/Compat.browser' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/4.5/Browsers/Compat.browser' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/4.0/Browsers/Compat.browser' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/2.0/Browsers/Compat.browser' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/4.0/Browsers/Compat.browser' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/bg-BG.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/bg-BG.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/bg-BG.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/gd-GB.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/gd-GB.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/gd-GB.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/lt-LT.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/lt-LT.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/lt-LT.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/da-DK.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/da-DK.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/da-DK.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/gl-ES.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/gl-ES.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/gl-ES.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/zh-CN.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/zh-CN.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/zh-CN.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Mesh/FirstPersonAnimBlueprint_Copy.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Mesh/FirstPersonAnimBlueprint_Copy.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Mesh/FirstPersonAnimBlueprint_Copy.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Mesh/FirstPersonAnimBlueprint_Copy.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Mesh/FirstPersonAnimBlueprint_Copy.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Mesh/FirstPersonAnimBlueprint_Copy.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Mesh/FirstPersonAnimBlueprint_Copy.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ms-MY.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ms-MY.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ms-MY.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/fil-PH.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/fil-PH.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/fil-PH.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/eu-ES.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/eu-ES.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/eu-ES.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/zh-TW.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/zh-TW.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/zh-TW.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/nl-NL.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/nl-NL.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/nl-NL.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/id-ID.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/id-ID.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/id-ID.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/fi-FI.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/fi-FI.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/fi-FI.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/sv-SE.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/sv-SE.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/sv-SE.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/it-IT.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/it-IT.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/it-IT.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/pt-PT.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/pt-PT.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/pt-PT.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/sl-SI.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/sl-SI.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/sl-SI.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/cs-CZ.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/cs-CZ.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/cs-CZ.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/tr-TR.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/tr-TR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/tr-TR.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/pt-BR.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/pt-BR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/pt-BR.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ro-RO.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ro-RO.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ro-RO.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/de-DE.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/de-DE.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/de-DE.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/pl-PL.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/pl-PL.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/pl-PL.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/Engine.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Engine.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/Engine.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/es-ES.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/es-ES.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/es-ES.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/sk-SK.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/sk-SK.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/sk-SK.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/kmr-TR.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/kmr-TR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/kmr-TR.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ko-KR.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ko-KR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ko-KR.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ca-ES.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ca-ES.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ca-ES.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/fr-FR.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/fr-FR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/fr-FR.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/en-US.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/en-US.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/en-US.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Old/D02E42700E40422F8BA0E36B9DB559EA/Players/2D182056000000000000000000000000.sav' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA-old/Players/2D182056000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Old/D02E42700E40422F8BA0E36B9DB559EA/Players/2D182056000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/Palworld-0207/D02E42700E40422F8BA0E36B9DB559EA/Players/2D182056000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Old/D02E42700E40422F8BA0E36B9DB559EA/Players/2D182056000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/New/D02E42700E40422F8BA0E36B9DB559EA/Players/2D182056000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Old/D02E42700E40422F8BA0E36B9DB559EA/Players/2D182056000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA/Players/2D182056000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Old/D02E42700E40422F8BA0E36B9DB559EA/Players/2D182056000000000000000000000000.sav' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/hu-HU.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/hu-HU.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/hu-HU.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/Level-Files/NATE.sav' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/Level-Files/594B2BBD000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/Level-Files/NATE.sav' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/4.0/settings.map' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/4.5/settings.map' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/4.0/settings.map' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/vi-VN.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/vi-VN.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/vi-VN.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ja-JP.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ja-JP.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ja-JP.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/he-IL.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/he-IL.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/he-IL.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ur-PK.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ur-PK.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ur-PK.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ar-SA.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ar-SA.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ar-SA.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/fa-IR.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/fa-IR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/fa-IR.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/bn-BD.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/bn-BD.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/bn-BD.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Textures/FirstPersonCrosshair.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Textures/FirstPersonCrosshair.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Textures/FirstPersonCrosshair.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Textures/FirstPersonCrosshair.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Textures/FirstPersonCrosshair.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Textures/FirstPersonCrosshair.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Textures/FirstPersonCrosshair.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA/Players/20382172000000000000000000000000.sav' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA-old/Players/20382172000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA/Players/20382172000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Old/D02E42700E40422F8BA0E36B9DB559EA/Players/20382172000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA/Players/20382172000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/Palworld-0207/D02E42700E40422F8BA0E36B9DB559EA/Players/20382172000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA/Players/20382172000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/New/D02E42700E40422F8BA0E36B9DB559EA/Players/20382172000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA/Players/20382172000000000000000000000000.sav' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/Palworld-0207/D02E42700E40422F8BA0E36B9DB559EA/Players/1000254E000000000000000000000000.sav' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA/Players/1000254E000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/Palworld-0207/D02E42700E40422F8BA0E36B9DB559EA/Players/1000254E000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Old/D02E42700E40422F8BA0E36B9DB559EA/Players/1000254E000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/Palworld-0207/D02E42700E40422F8BA0E36B9DB559EA/Players/1000254E000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/New/D02E42700E40422F8BA0E36B9DB559EA/Players/1000254E000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/Palworld-0207/D02E42700E40422F8BA0E36B9DB559EA/Players/1000254E000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA-old/Players/1000254E000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/Palworld-0207/D02E42700E40422F8BA0E36B9DB559EA/Players/1000254E000000000000000000000000.sav' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/hy-AM.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/hy-AM.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/hy-AM.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA-old/Players/594B2BBD000000000000000000000000.sav' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/New/D02E42700E40422F8BA0E36B9DB559EA/Players/594B2BBD000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA-old/Players/594B2BBD000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/Palworld-0207/D02E42700E40422F8BA0E36B9DB559EA/Players/594B2BBD000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA-old/Players/594B2BBD000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA/Players/594B2BBD000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA-old/Players/594B2BBD000000000000000000000000.sav' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/uk-UA.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/uk-UA.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/uk-UA.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ru-RU.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ru-RU.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ru-RU.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/el-GR.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/el-GR.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/el-GR.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/New/D02E42700E40422F8BA0E36B9DB559EA/Players/14506862000000000000000000000000.sav' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA/Players/14506862000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/New/D02E42700E40422F8BA0E36B9DB559EA/Players/14506862000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/Palworld-0207/D02E42700E40422F8BA0E36B9DB559EA/Players/14506862000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/New/D02E42700E40422F8BA0E36B9DB559EA/Players/14506862000000000000000000000000.sav' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/hi-IN.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/hi-IN.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/hi-IN.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/th-TH.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/th-TH.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/th-TH.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ka-GE.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/locale/ka-GE.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/locale/ka-GE.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Old/D02E42700E40422F8BA0E36B9DB559EA/Players/A30ECC2A000000000000000000000000.sav' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/tests/A30ECC2A000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Old/D02E42700E40422F8BA0E36B9DB559EA/Players/A30ECC2A000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/A30ECC2A000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Old/D02E42700E40422F8BA0E36B9DB559EA/Players/A30ECC2A000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/Player-Files/A30ECC2A000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Old/D02E42700E40422F8BA0E36B9DB559EA/Players/A30ECC2A000000000000000000000000.sav' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/New/D02E42700E40422F8BA0E36B9DB559EA/Players/A30ECC2A000000000000000000000000.sav' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA/Players/A30ECC2A000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/New/D02E42700E40422F8BA0E36B9DB559EA/Players/A30ECC2A000000000000000000000000.sav' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/A30ECC2A000000000000000000000002.sav' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/A30ECC2A000000000000000000000002-2.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/A30ECC2A000000000000000000000002.sav' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/A30ECC2A000000000000000000000022.sav' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/A30ECC2A000000000000000000000033.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/A30ECC2A000000000000000000000022.sav' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/A30ECC2A000000000000000000000000.sav' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/Palworld-0207/D02E42700E40422F8BA0E36B9DB559EA/Players/A30ECC2A000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/A30ECC2A000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/Fixed/D02E42700E40422F8BA0E36B9DB559EA-old/Players/A30ECC2A000000000000000000000000.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/A30ECC2A000000000000000000000000.sav' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/A30ECC2A0000000000000000000000002.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/A30ECC2A000000000000000000000000.sav' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/helpers/cheahjs-save-tools/palworld_save_tools/commands/convert.py' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/helpers/cheahjs-save-tools/convert.py' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/pave-v2.0.9.zip-338-2-0-9-1707362138/helpers/cheahjs-save-tools/palworld_save_tools/commands/convert.py' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/chaoscore_org/chaoscore_org.ca-bundle' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/doomrampage/doomrampage_org.ca-bundle' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/chaoscore_org/chaoscore_org.ca-bundle' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/Config/CoalescedSourceConfigs/Lightmass.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/Config/CoalescedSourceConfigs/Lightmass.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/Config/CoalescedSourceConfigs/Lightmass.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Intermediate/ShaderAutogen/PCD3D_ES31/AutogenShaderHeaders.ush' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Intermediate/ShaderAutogen/PCD3D_ES31/AutogenShaderHeaders.ush' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Intermediate/ShaderAutogen/PCD3D_ES31/AutogenShaderHeaders.ush' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Intermediate/ShaderAutogen/PCD3D_SM5/AutogenShaderHeaders.ush' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Intermediate/ShaderAutogen/PCD3D_SM5/AutogenShaderHeaders.ush' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Intermediate/ShaderAutogen/PCD3D_SM5/AutogenShaderHeaders.ush' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_PhysicsAsset.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_PhysicsAsset.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_PhysicsAsset.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_PhysicsAsset.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_PhysicsAsset.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_PhysicsAsset.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_PhysicsAsset.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/error.html' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser-page/error.html' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/OBS-Studio-29.1.3/data/obs-plugins/obs-browser/error.html' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_Skeleton.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_Skeleton.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_Skeleton.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_Skeleton.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_Skeleton.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_Skeleton.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms_Skeleton.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_GRAY.png' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_GRAY1.png' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_GRAY.png' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_BLACK.png' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_BLACK1.png' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_BLACK.png' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_DARKGREEN.png' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_DARKGREEN1.png' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_DARKGREEN.png' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_GREEN.png' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_GREEN1.png' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_GREEN.png' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_GOLD.png' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_GOLD1.png' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_GOLD.png' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_LIGHTBLUE.png' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_LIGHTBLUE1.png' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Resources/CHART_LIGHTBLUE.png' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/FirstPersonGameMode.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPersonBP/Blueprints/FirstPersonGameMode.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/FirstPersonGameMode.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPersonBP/Blueprints/FirstPersonGameMode.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/FirstPersonGameMode.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPersonBP/Blueprints/FirstPersonGameMode.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/FirstPersonGameMode.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Editor.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/Editor.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/Editor.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/Level-Files/594B2BBD000000000000000000000000.sav.json' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/Level-Files/NATE.sav.json' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/Level-Files/594B2BBD000000000000000000000000.sav.json' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Config/DefaultEngine.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Config/DefaultEngine.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Config/DefaultEngine.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Intermediate/ShaderAutogen/PCD3D_SM6/AutogenShaderHeaders.ush' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Intermediate/ShaderAutogen/PCD3D_SM5/AutogenShaderHeaders.ush' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Avalon/Intermediate/ShaderAutogen/PCD3D_SM6/AutogenShaderHeaders.ush' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/FileTypesMan.chm' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/filetypesman-x64/FileTypesMan.chm' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/FileTypesMan.chm' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/readme.txt' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/filetypesman-x64/readme.txt' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/readme.txt' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Config/DefaultInput.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Config/DefaultInput.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Config/DefaultInput.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Config/DefaultInput.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Config/DefaultInput.ini' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Config/DefaultInput.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Config/DefaultInput.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/JustinHeffronResumeKCCU.docx' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/JustinHeffronResumeKCCU (1).docx' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/JustinHeffronResumeKCCU.docx' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/AutoScreenshot.png' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/AutoScreenshot.png' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/AutoScreenshot.png' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/A30ECC2A000000000000000000000022.sav.json' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/A30ECC2A000000000000000000000033.sav.json' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/A30ECC2A000000000000000000000022.sav.json' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/A30ECC2A0000000000000000000000002.sav.json' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/A30ECC2A0000000000000000000000002.sav.json' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/0207/A30ECC2A0000000000000000000000002.sav.json' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/DropingthingsLibrary_Auto8.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/DropingthingsLibrary_Auto8.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/DropingthingsLibrary_Auto8.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/flashlighttexture.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/Flashlight/flashlighttexture.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/flashlighttexture.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Modles/Flashlight/flashlighttexture.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/flashlighttexture.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Modles/Flashlight/flashlighttexture.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/flashlighttexture.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/FirstPersonOverview.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPersonBP/FirstPersonOverview.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/FirstPersonOverview.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPersonBP/FirstPersonOverview.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/FirstPersonOverview.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPersonBP/FirstPersonOverview.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/FirstPersonOverview.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/Config/CoalescedSourceConfigs/Editor.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/Config/CoalescedSourceConfigs/Editor.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/Config/CoalescedSourceConfigs/Editor.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/DropingthingsLibrary.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPersonBP/Blueprints/DropingthingsLibrary.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/DropingthingsLibrary.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPersonBP/Blueprints/DropingthingsLibrary.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/DropingthingsLibrary.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPersonBP/Blueprints/DropingthingsLibrary.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/DropingthingsLibrary.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/FirstPersonHUD.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPersonBP/Blueprints/FirstPersonHUD.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/FirstPersonHUD.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPersonBP/Blueprints/FirstPersonHUD.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/FirstPersonHUD.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPersonBP/Blueprints/FirstPersonHUD.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/FirstPersonHUD.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Drives/1030.ico' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Drives/1035.ico' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Drives/1030.ico' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/4.5/DefaultWsdlHelpGenerator.aspx' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/4.0/DefaultWsdlHelpGenerator.aspx' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/4.5/DefaultWsdlHelpGenerator.aspx' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/2.0/DefaultWsdlHelpGenerator.aspx' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Project 06 - Silver Release/MonoBleedingEdge/etc/mono/4.5/DefaultWsdlHelpGenerator.aspx' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/DropingthingsLibrary_Auto9.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/DropingthingsLibrary_Auto9.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/DropingthingsLibrary_Auto9.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Misc/14.ico' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/HomeGroup.ico' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Misc/14.ico' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/AChars.resx' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Options.resx' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/AChars.resx' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/Support.resx' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/AChars.resx' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/VisualVincent.resx' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/DoomWriter-master/DoomWriter-master/Doom Text Writer Source Code/Doom Text Writer/AChars.resx' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/Flashlightlense.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/Flashlight/Flashlightlense.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/Flashlightlense.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Modles/Flashlight/Flashlightlense.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/Flashlightlense.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Modles/Flashlight/Flashlightlense.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/Flashlightlense.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/LIGHT.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/LIGHT.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/LIGHT.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Modles/CameraTripod/LIGHT.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/LIGHT.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Modles/CameraTripod/LIGHT.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/LIGHT.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/CubeMaterial.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/WorldObjects/Meshes/CubeMaterial.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/CubeMaterial.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/WorldObjects/Meshes/CubeMaterial.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/CubeMaterial.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/WorldObjects/Meshes/CubeMaterial.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/CubeMaterial.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/Flashlight/FlashLightMaterial.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/FlashLightMaterial.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/Flashlight/FlashLightMaterial.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Modles/Flashlight/FlashLightMaterial.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/Flashlight/FlashLightMaterial.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Modles/Flashlight/FlashLightMaterial.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/Flashlight/FlashLightMaterial.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Textures/UE4_LOGO_CARD.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Textures/UE4_LOGO_CARD.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Textures/UE4_LOGO_CARD.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Textures/UE4_LOGO_CARD.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Textures/UE4_LOGO_CARD.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Textures/UE4_LOGO_CARD.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Textures/UE4_LOGO_CARD.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPersonFire_Montage.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPersonFire_Montage.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPersonFire_Montage.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Animations/FirstPersonFire_Montage.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPersonFire_Montage.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Animations/FirstPersonFire_Montage.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPersonFire_Montage.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/1M_Cube.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/WorldObjects/Meshes/1M_Cube.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/1M_Cube.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/WorldObjects/Meshes/1M_Cube.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/1M_Cube.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/WorldObjects/Meshes/1M_Cube.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/1M_Cube.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/lens.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/lens.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/lens.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Modles/CameraTripod/lens.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/lens.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Modles/CameraTripod/lens.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/lens.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Meshes/CubeMaterialOverride.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Meshes/CubeMaterialOverride.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Meshes/CubeMaterialOverride.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Meshes/CubeMaterialOverride.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Meshes/CubeMaterialOverride.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Meshes/CubeMaterialOverride.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Meshes/CubeMaterialOverride.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Drives/135.ico' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Drives/136.ico' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Drives/135.ico' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/Modles/CameraTripod/BasicCamera_Cube_Auto2.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/Modles/CameraTripod/BasicCamera_Cube_Auto2.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/Modles/CameraTripod/BasicCamera_Cube_Auto2.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/Tripod_skin_1.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/Tripod_skin_1.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/Tripod_skin_1.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Modles/CameraTripod/Tripod_skin_1.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/Tripod_skin_1.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Modles/CameraTripod/Tripod_skin_1.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/Tripod_skin_1.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/BasicCamera_Cube.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/BasicCamera_Cube.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/BasicCamera_Cube.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Modles/CameraTripod/BasicCamera_Cube.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/BasicCamera_Cube.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Modles/CameraTripod/BasicCamera_Cube.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/BasicCamera_Cube.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_JumpEnd.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_JumpEnd.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_JumpEnd.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Animations/FirstPerson_JumpEnd.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_JumpEnd.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Animations/FirstPerson_JumpEnd.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_JumpEnd.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/Cameraskin.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/Cameraskin.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/Cameraskin.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Modles/CameraTripod/Cameraskin.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/Cameraskin.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Modles/CameraTripod/Cameraskin.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/Cameraskin.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/1M_Cube_Chamfer.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/WorldObjects/Meshes/1M_Cube_Chamfer.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/1M_Cube_Chamfer.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/WorldObjects/Meshes/1M_Cube_Chamfer.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/1M_Cube_Chamfer.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/WorldObjects/Meshes/1M_Cube_Chamfer.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/1M_Cube_Chamfer.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_Fire.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_Fire.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_Fire.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Animations/FirstPerson_Fire.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_Fire.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Animations/FirstPerson_Fire.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_Fire.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/Flashlight/Material.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/Material.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/Flashlight/Material.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Modles/Flashlight/Material.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/Flashlight/Material.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Modles/Flashlight/Material.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/Flashlight/Material.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_JumpStart.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_JumpStart.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_JumpStart.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Animations/FirstPerson_JumpStart.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_JumpStart.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Animations/FirstPerson_JumpStart.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_JumpStart.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige_LOGO.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige_LOGO.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige_LOGO.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige_LOGO.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige_LOGO.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige_LOGO.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_Plastic_Shiny_Beige_LOGO.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_Run.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_Run.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_Run.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Animations/FirstPerson_Run.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_Run.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Animations/FirstPerson_Run.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_Run.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/Tripod_Skin_2.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/Tripod_Skin_2.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/Tripod_Skin_2.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Modles/CameraTripod/Tripod_Skin_2.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/Tripod_Skin_2.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Modles/CameraTripod/Tripod_Skin_2.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/Tripod_Skin_2.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/WorldObjects/Meshes/TemplateFloor.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/WorldObjects/Meshes/TemplateFloor.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/WorldObjects/Meshes/TemplateFloor.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/WorldObjects/Meshes/TemplateFloor.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/WorldObjects/Meshes/TemplateFloor.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/WorldObjects/Meshes/TemplateFloor.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/WorldObjects/Meshes/TemplateFloor.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_JumpLoop.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_JumpLoop.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_JumpLoop.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Animations/FirstPerson_JumpLoop.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_JumpLoop.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Animations/FirstPerson_JumpLoop.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_JumpLoop.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_GlossyBlack_Latex_UE4.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/ML_GlossyBlack_Latex_UE4.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_GlossyBlack_Latex_UE4.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/ML_GlossyBlack_Latex_UE4.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_GlossyBlack_Latex_UE4.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/ML_GlossyBlack_Latex_UE4.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_GlossyBlack_Latex_UE4.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_SoftMetal_UE4.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/ML_SoftMetal_UE4.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_SoftMetal_UE4.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/ML_SoftMetal_UE4.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_SoftMetal_UE4.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/ML_SoftMetal_UE4.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/ML_SoftMetal_UE4.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto6.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto6.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto6.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_Idle.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_Idle.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_Idle.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Animations/FirstPerson_Idle.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_Idle.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Animations/FirstPerson_Idle.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_Idle.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Meshes/BaseMaterial.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Meshes/BaseMaterial.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Meshes/BaseMaterial.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Meshes/BaseMaterial.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Meshes/BaseMaterial.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Meshes/BaseMaterial.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Meshes/BaseMaterial.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/Camera_Auto2.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/Camera_Auto2.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/Camera_Auto2.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/EditorPerProjectUserSettings.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Config/Windows/EditorPerProjectUserSettings.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Config/Windows/EditorPerProjectUserSettings.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto0.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto0.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto0.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/Modles/CameraTripod/BasicCamera_Tripot_Auto2.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/Modles/CameraTripod/BasicCamera_Tripot_Auto2.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/Modles/CameraTripod/BasicCamera_Tripot_Auto2.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/BasicCamera_Tripot.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/CameraTripod/BasicCamera_Tripot.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/BasicCamera_Tripot.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Modles/CameraTripod/BasicCamera_Tripot.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/BasicCamera_Tripot.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Modles/CameraTripod/BasicCamera_Tripot.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/CameraTripod/BasicCamera_Tripot.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto1.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto1.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto1.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto9.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto9.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto9.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPersonBP/Blueprints/VideoCamera.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/VideoCamera.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPersonBP/Blueprints/VideoCamera.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPersonBP/Blueprints/VideoCamera.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPersonBP/Blueprints/VideoCamera.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto8.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto8.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto8.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto7.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto7.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/VideoCamera_Auto7.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/Camera_Auto3.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/Camera_Auto3.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/Camera_Auto3.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/Camera_Auto4.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/Camera_Auto4.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/Camera_Auto4.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Logs/Evidence_2.log' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Logs/Evidence_2.log' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Logs/Evidence_2.log' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashContext.runtime-xml' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashContext.runtime-xml' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashContext.runtime-xml' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashContext.runtime-xml' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashContext.runtime-xml' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashContext.runtime-xml' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/CrashContext.runtime-xml' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/Config/CoalescedSourceConfigs/Engine.ini' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/Config/CoalescedSourceConfigs/Engine.ini' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/Config/CoalescedSourceConfigs/Engine.ini' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/M_UE4Man_Body.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/M_UE4Man_Body.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/M_UE4Man_Body.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Materials/M_UE4Man_Body.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/M_UE4Man_Body.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Materials/M_UE4Man_Body.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/M_UE4Man_Body.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Logs/Evidence-backup-2022.04.24-22.20.12.log' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Logs/Evidence-backup-2022.04.24-22.20.12.log' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Logs/Evidence-backup-2022.04.24-22.20.12.log' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/filetypesman-x64/FileTypesMan.exe' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/FileTypesMan.exe' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/filetypesman-x64/FileTypesMan.exe' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto0.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto0.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto0.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Textures/UE4_Mannequin_MAT_MASKA.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Textures/UE4_Mannequin_MAT_MASKA.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Textures/UE4_Mannequin_MAT_MASKA.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Textures/UE4_Mannequin_MAT_MASKA.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Textures/UE4_Mannequin_MAT_MASKA.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Textures/UE4_Mannequin_MAT_MASKA.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Textures/UE4_Mannequin_MAT_MASKA.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_AnimBP.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Animations/FirstPerson_AnimBP.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_AnimBP.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Animations/FirstPerson_AnimBP.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_AnimBP.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Animations/FirstPerson_AnimBP.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Animations/FirstPerson_AnimBP.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Kuyen (flat)/applications-education-school.ico' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Kuyen (flat)/applications-education.ico' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Kuyen (flat)/applications-education-school.ico' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Kuyen (flat)/applications-education-science.ico' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Kuyen (flat)/applications-science.ico' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Kuyen (flat)/applications-education-science.ico' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Antu (gradient)/applications-education-science.ico' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Antu (gradient)/applications-science.ico' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Antu (gradient)/applications-education-science.ico' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Antu (gradient)/phone.ico' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Antu (gradient)/smartphone.ico' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Antu (gradient)/phone.ico' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Antu (gradient)/folder-development.ico' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Antu (gradient)/folder-script.ico' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Antu (gradient)/folder-development.ico' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto8.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto8.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto8.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Kuyen (flat)/application-menu.ico' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Kuyen (flat)/configure.ico' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Kuyen (flat)/application-menu.ico' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Antu (gradient)/folder-documents.ico' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Antu (gradient)/folder-text.ico' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Antu (gradient)/folder-documents.ico' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Logs/Evidence.log' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Logs/Evidence.log' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Logs/Evidence.log' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Audio/FirstPersonTemplateWeaponFire02.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Audio/FirstPersonTemplateWeaponFire02.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Audio/FirstPersonTemplateWeaponFire02.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Audio/FirstPersonTemplateWeaponFire02.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Audio/FirstPersonTemplateWeaponFire02.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Audio/FirstPersonTemplateWeaponFire02.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Audio/FirstPersonTemplateWeaponFire02.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto7.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto7.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto7.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Kuyen (flat)/folder-documents.ico' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Kuyen (flat)/folder-text.ico' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/Icons/Windows Icons/Kuyen (flat)/folder-documents.ico' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto2.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto2.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto2.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto9.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto9.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto9.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto1.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto1.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto1.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto5.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto5.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto5.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto3.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto3.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto3.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/FirstPersonCharacter.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPersonBP/Blueprints/FirstPersonCharacter.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/FirstPersonCharacter.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPersonBP/Blueprints/FirstPersonCharacter.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Blueprints/FirstPersonCharacter.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto4.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto4.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto4.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto6.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto6.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Blueprints/FirstPersonCharacter_Auto6.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/UE4Minidump.dmp' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/UE4Minidump.dmp' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/UE4Minidump.dmp' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/UE4Minidump.dmp' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/UE4Minidump.dmp' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/UE4Minidump.dmp' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/UE4Minidump.dmp' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/Level-Files/Level-0.sav' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/fixed/Level.sav' '/home/theron/mnt/cachyos/Dropbox/Archives/Windows/Downloads/palworld-save-tools-main/Level-Files/Level-0.sav' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/Flashlight/BasicFlashlight_Auto1.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/Flashlight/BasicFlashlight_Auto1.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/Flashlight/BasicFlashlight_Auto1.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/BasicFlashlight.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/Modles/Flashlight/BasicFlashlight.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/BasicFlashlight.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/Modles/Flashlight/BasicFlashlight.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/BasicFlashlight.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/Modles/Flashlight/BasicFlashlight.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/Modles/Flashlight/BasicFlashlight.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Github Repos/Rampage-Stats/Rampage-Stats/src/GRAPHICS/CONBACK.lmp' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Github Repos/Rampage-Stats/Rampage-Stats/src/GRAPHICS/TITLEPIC.lmp' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Github Repos/Rampage-Stats/Rampage-Stats/src/GRAPHICS/CONBACK.lmp' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Mesh/SK_Mannequin_Arms.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/Evidence.log' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/Evidence.log' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/Evidence.log' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/Evidence.log' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/Evidence.log' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/Evidence.log' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Crashes/UE4CC-Windows-5608E4424B821624D82690AD1B7E9853_0000/Evidence.log' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01_N.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01_N.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01_N.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01_N.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01_N.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01_N.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01_N.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_N.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_N.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_N.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_N.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_N.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_N.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_N.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_D.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_D.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_D.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_D.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_D.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_D.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Rubber_Blue_01_D.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Textures/UE4_Mannequin__normals.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Textures/UE4_Mannequin__normals.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Textures/UE4_Mannequin__normals.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Textures/UE4_Mannequin__normals.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Textures/UE4_Mannequin__normals.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Textures/UE4_Mannequin__normals.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Textures/UE4_Mannequin__normals.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Maps/FirstPersonExampleMap_BuiltData.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPersonBP/Maps/FirstPersonExampleMap_BuiltData.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Maps/FirstPersonExampleMap_BuiltData.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPersonBP/Maps/FirstPersonExampleMap_BuiltData.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Maps/FirstPersonExampleMap_BuiltData.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPersonBP/Maps/FirstPersonExampleMap_BuiltData.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Maps/FirstPersonExampleMap_BuiltData.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto0.umap' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto0.umap' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto0.umap' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/CachedAssetRegistry.bin' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Intermediate/CachedAssetRegistry.bin' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Intermediate/CachedAssetRegistry.bin' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto5.umap' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto5.umap' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto5.umap' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto7.umap' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto7.umap' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto7.umap' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto2.umap' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto2.umap' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto2.umap' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto4.umap' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto4.umap' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto4.umap' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto6.umap' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto6.umap' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto6.umap' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto8.umap' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto8.umap' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto8.umap' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01.uasset' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01.uasset' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01.uasset' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPerson/Character/Materials/MaterialLayers/T_ML_Aluminum01.uasset' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto9.umap' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto9.umap' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto9.umap' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto3.umap' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto3.umap' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto3.umap' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto1.umap' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto1.umap' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Saved/Autosaves/Game/FirstPersonBP/Maps/FirstPersonExampleMap_Auto1.umap' # duplicate

original_cmd  '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPersonBP/Maps/FirstPersonExampleMap.umap' # original
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/Evidence/Evidence/Content/FirstPersonBP/Maps/FirstPersonExampleMap.umap' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPersonBP/Maps/FirstPersonExampleMap.umap' # duplicate
remove_cmd    '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld 5.0/Content/FirstPersonBP/Maps/FirstPersonExampleMap.umap' '/home/theron/mnt/cachyos/Dropbox/Archives/ChaosCore/Unreal Projects/EvidenceOld/Content/FirstPersonBP/Maps/FirstPersonExampleMap.umap' # duplicate
                                               
                                               
                                               
######### END OF AUTOGENERATED OUTPUT #########
                                               
if [ $PROGRESS_CURR -le $PROGRESS_TOTAL ]; then
    print_progress_prefix                      
    echo "${COL_BLUE}Done!${COL_RESET}"      
fi                                             
                                               
if [ -z $DO_REMOVE ] && [ -z $DO_DRY_RUN ]     
then                                           
  echo "Deleting script " "$0"             
  rm -f '$CORE_CFG/yazi/rmlint.sh';                                     
fi                                             
