##################################[ disk_usage: disk usage ]##################################
# Colors for different levels of disk usage.
typeset -g POWERLEVEL9K_DISK_USAGE_NORMAL_FOREGROUND=2
typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_FOREGROUND=3
typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_FOREGROUND=1
# Thresholds for different levels of disk usage (percentage points).
typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL=90
typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL=95
# If set to true, hide disk usage when below $POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL percent.
typeset -g POWERLEVEL9K_DISK_USAGE_ONLY_WARNING=false
# Custom icon.
# typeset -g POWERLEVEL9K_DISK_USAGE_VISUAL_IDENTIFIER_EXPANSION='⭐'

######################################[ ram: free RAM ]#######################################
# RAM color.
typeset -g POWERLEVEL9K_RAM_FOREGROUND=2
# Custom icon.
# typeset -g POWERLEVEL9K_RAM_VISUAL_IDENTIFIER_EXPANSION='⭐'

#####################################[ swap: used swap ]######################################
# Swap color.
typeset -g POWERLEVEL9K_SWAP_FOREGROUND=3
# Custom icon.
# typeset -g POWERLEVEL9K_SWAP_VISUAL_IDENTIFIER_EXPANSION='⭐'

######################################[ load: CPU load ]######################################
# Show average CPU load over this many last minutes. Valid values are 1, 5 and 15.
typeset -g POWERLEVEL9K_LOAD_WHICH=5
# Load color when load is under 50%.
typeset -g POWERLEVEL9K_LOAD_NORMAL_FOREGROUND=2
# Load color when load is between 50% and 70%.
typeset -g POWERLEVEL9K_LOAD_WARNING_FOREGROUND=3
# Load color when load is over 70%.
typeset -g POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND=1
# Custom icon.
# typeset -g POWERLEVEL9K_LOAD_VISUAL_IDENTIFIER_EXPANSION='⭐'

################[ todo: todo items (https://github.com/todotxt/todo.txt-cli) ]################
# Todo color.
typeset -g POWERLEVEL9K_TODO_FOREGROUND=4
# Hide todo when the total number of tasks is zero.
typeset -g POWERLEVEL9K_TODO_HIDE_ZERO_TOTAL=true
# Hide todo when the number of tasks after filtering is zero.
typeset -g POWERLEVEL9K_TODO_HIDE_ZERO_FILTERED=false

# Todo format. The following parameters are available within the expansion.
#
# - P9K_TODO_TOTAL_TASK_COUNT     The total number of tasks.
# - P9K_TODO_FILTERED_TASK_COUNT  The number of tasks after filtering.
#
# These variables correspond to the last line of the output of `todo.sh -p ls`:
#
#   TODO: 24 of 42 tasks shown
#
# Here 24 is P9K_TODO_FILTERED_TASK_COUNT and 42 is P9K_TODO_TOTAL_TASK_COUNT.
#
# typeset -g POWERLEVEL9K_TODO_CONTENT_EXPANSION='$P9K_TODO_FILTERED_TASK_COUNT'

# Custom icon.
# typeset -g POWERLEVEL9K_TODO_VISUAL_IDENTIFIER_EXPANSION='⭐'
