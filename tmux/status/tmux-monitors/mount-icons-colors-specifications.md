# Local/Remote Disk Storage

this module will replace the disk usage module we have on the status bar but for now implement it as
a stand alone module with the other one staying where it is as a working fill in until we get this
fully implemented.

## Global Icon and Color Definitions

- STATUS_BG_COLOR=#292D3E
- TAB_BG_COLOR=#444267
- TAB_TEXT_COLOR=#cdd6f4

- MOUNTED_STATE_COLOR
  - NOT_MOUNTED=#FF5370
  - MOUNTED=#acf200

- STORAGE_USE_PERCENTAGE_COLOR:

```
# Color coding based on usage
  local color=""
  if [ "$percent" -ge 90 ]; then
    color="#[fg=red,bold]"
  elif [ "$percent" -ge 75 ]; then
    color="#[fg=yellow]"
  else
    color="#[fg=cyan]"
  fi
```

- CLOUD_STORAGE_COLORS

```
dropbox="#024CC4:"
proton="#6948F5"
onedrive="#FFB900"
gdrive="#34A853"
chaoscore="#01F9C6"
zfold="#182FAB"
```

- STORAGE_ICONS

```bash
nvmem2=" "
nvme="󰨆 "
hdd="󰋊 "
proton="󰢬 "
dropbox=" "
onedrive="󰏊 "
gdrive="󰊶 "
zfold="󰓷 "
chaoscore=" "
```

## Storage Tabs Styling

### Local Styling

- Local Storage should use its storage usage percentage as its tab divider color

Example Output: `󰨆  68% 󰋊  41% `

Example Definitions:

```tmux
STATUS_BAR_DIVIDER=""
STORAGE_TAB_BAR_DIVIDER=""

TAB_CLOUD_STORAGE_TEXT="#[fg=#$PERCENT_USAGE_COLOR,bg=$TAB_BG_COLOR]"
TAB_BEGINNING_DIVIDER="#[fg=${$STORAGE_USAGE_COLOR},bg=${STATUS_BG_COLOR},#[bg=${STATUS_BG_COLOR}]]"
TAB_ICON="#[fg=$TAB_TEXT_COLOR,bg=${LOCAL_TAB_BG_COLOR}]$LOCAL_STORAGE_ICON"
TAB_TEXT="#[fg=$TAB_TEXT_COLOR,bg=$TAB_BG_COLOR]$STORAGE_USAGE_PERCENTAGE
TAB_END_NEW_TAB_DIVIER=#[fg=$STORAGE_USAGE_COLOR,bg=$TAB_BG_COLOR]
TAB_ENDING_DIVIDER=#[fg=$STATUS_Y_BG_COLOR,bg=$TAB_BG_COLOR]"
```

> NOTE

    The last storage tab needs to have the STATUS_BAR_DIVIDER, with the fg color being the color of the background color of the next section in the status bar.

### Remote Styling

- Remote/Cloud Tab colors are predefined in the list above.

```
TAB_CLOUD_STORAGE_TEXT=#[fg=#$PERCENT_USAGE_COLOR,bg=$TAB_BG_COLOR]
TAB_BEGINNING_DIVIDER=#{$isMounted, #[fg=${CLOUD_STORAGE_COLOR},bg=${STATUS_BG_COLOR},#[fg=${NOT_MOUNTED_COLOR},bg=${STATUS_BG_COLOR}]]
TAB_ICON=#[fg=$TAB_TEXT_COLOR,bg=${CLOUD_STORAGE_COLOR}]$CLOUD_STORAGE_ICON
TAB_TEXT=#[fg=$TAB_TEXT_COLOR,bg=$TAB_BG_COLOR]$CLOUD_STORAGE_USAGE_PERCENTAGE
TAB_ENDING_DIVIDER=#[fg=$MOUNTED_STATE_COLOR,bg=$NEXT_BACKGROUND_COLOR]
```

### IMPORTANT

    - $NEXT_BACKGROUND_COLOR will be the $LOCAL_DISK_TAB_COLOR, unless it's the last local disk entry in the list, then it should be, $TABLINE_Y_BG_COLOR

## Storage Tabs position on the TMUX Status Bar

- Local Storage
  - Location: Top(first) status bar, align right, before the the time module
  - Format:

```bash
${TAB_BEGINNING_DIVIDER}${TAB_ICON} ${TAB_TEXT} ${TAB_ENDING_DIVIER}
```

- Cloud Storage:
  - Location: Bottom(second) tmux status bar, align center
  - Format:

```bash
${TAB_BEGINNING_DIVIDER}${TAB_ICON} ${TAB_TEXT} ${TAB_ENDING_DIVIER}
```

# Storage Maintenance Tasks/Processes as Tabs

### Task Type Icons

- Download: 󰶡
- Upload: 󰶣
- Compression: 󰗄
- Transfer: 󰔰 (Remote to Remote)

Any tasks happening between a remote or cloud storage should be tracked. - Cloud Syncrhonization
Any clouds that are actively syncing on the system, if possible give a syncing percentage, output the percentage as follows:

### Progress Formatting: Colors and Icons

- Perecentage Full Colors
  - 90% and Above: #FF5370
  - 75% - 90%: #F78C6C
  - 50% - 75%: #FFCB6B
  - 35% - 50%: #E5D68A
  - 15% - 35%: #B5E48C
  - Below 15%: #81f8bf

- Percentage Color Definitions
  - 90% and Above:#81f8bf
  - 70-90%:#B5E48C
  - 50% - 70%:#E5D68A
  - 35% - 50%:#FFCB6B
  - 15% - 35%:#F78C6C
  - below 15%:#FF5370

- Progress Icon Definition
  - 󰋙 below 10%
  - 󰫃 10%-25%
  - 󰫄 25%-50%
  - 󰫅 50-65%
  - 󰫆 65%-85%
  - 󰫇 85-99%
  - 󰫈 100%

## Downloads/Upload Task Formatting

> Examples:

- Download: ` 󰶡 25% 󰫃`

Example Format:

```bash
$TASK_TAB_BEGIN_DIVIDER_ICON $REMOTE_ICON $TASK_ICON $TASK_PERCENTAGE $TASK_PERCENTAGE_ICON $TASK_TAB_END_DIVIDER
```

- Upload: ` 󰶣 50% 󰫃`

> Example Format:

```bash
$TASK_TAB_BEGIN_DIVIDER_ICON$REMOTE_ICON $TASK_ICON $TASK_PERCENTAGE $TASK_PERCENTAGE_ICON$TASK_TAB_END_DIVIDER
```

- Transfer: ` 󰔰 󰢬 25% 󰫃`

Example Format:

```bash
$TASK_TAB_BEGIN_DIVIDER_ICON$REMOTE_ICON $TASK_ICON $REMOTE_TARGET_ICON $TASK_PERCENTAGE $TASK_PERCENTAGE_ICON$TASK_TAB_END_DIVIDER
```

## Compression Task Formatting

- Compression: `󰗄 .tar 5% 󰫃`

Example Format:

```bash
$TASK_TAB_BEGIN_DIVIDER_ICON$TASK_ICON $TASK_COMPRESSION_LABEL $TASK_PERCENTAGE $TASK_PERCENTAGE_ICON$TASK_TAB_END_DIVIDER
```

### Example Definitions for TMUX

> NOTICE

    These variables are not defined yet, they the desired context of what the styling should be. Fix any and all syntax errors within the examples.

```tmux
TASK_TAB_BEGIN_DIVIDER_ICON=""
TASK_TAB_END_DIVDER_ICON=""
TASK_TAB_BEGINNING=#[fg=${TAB_TEXT_COLOR},bg=${CLOUD_STORAGE_COLOR}]$TASK_TAB_BEGIN_DIVDER_ICON $CLOUD_STORAGE_ICON
TASK_TAB_LABEL=#[fg=${TAB_TEXT_COLOR},bg=${TAB_BG_COLOR}]$TASK_ICON $TASK_PERCENTAGE_NUMBER
TASK_TASK_END=#[fg=${TAB_TEXT_COLOR},bg=${TASK_PROGRESS_COLOR}]
${PROGRESS_STATUS_ICON}${TAB_END_DIVIDER_ICON}
```

## Task/Process Tabs TMUX Status line Position Specifications

These tabs are should be aligned in the center on the status line[1] (second status) line, they should append next to each other in the order they were started in, first come first serve.

# Total Active/Queued Task Tabs

Finally, for each type of active task, we will make a tab for the active/queued/total number of tasks/processes for each task type in the following formats:

Desired output logic:

`Active Tasks / Icon / Active Task Speed / Total Tasks(Of Task Type)`

Example Outputs:

Download: `1 󰶡 1.5 Mb/s  2`
Upload: `1 󰶣 2.2 Mb/s 2`
Compression: `1 󰗄 5kb/s 1`

### Example Definitions for TMUX

> NOTICE

    These variables are not defined yet, they the desired context of what the styling should be. Fix any and all syntax errors within the examples.

```tmux
TAB_BEGIN_DIVIDER_ICON=""
TAB_END_DIVDER_ICON=""
ACTIVE_TASK_TAB_BEGINNING=#[fg=${TAB_TEXT_COLOR},bg=${ACTIVE_TASK_BG_COLOR}]$TASK_TAB_BEGIN_DIVDER_ICON$ACTIVE_DOWNLOADS_COUNT TASK_TAB_LABEL=#[fg=${TAB_TEXT_COLOR},bg=${TAB_BG_COLOR}]$DOWNLOAD_ICON $ACTIVE_DOWNLOAD_SPEED
TASK_TASK_END=#[fg=${TAB_TEXT_COLOR},bg=${TASK_PROGRESS_COLOR}]$QUEUED_DOWNLOAD_TASKS$TAB_END_DIVIDER_ICON
```

## Active/Queued Task Tabs TMUX Status line Position Specifications

These will be aligned on the right of the tmux status-line [1], these will append in order in the same way the task/process tabs do, first come first serve.
