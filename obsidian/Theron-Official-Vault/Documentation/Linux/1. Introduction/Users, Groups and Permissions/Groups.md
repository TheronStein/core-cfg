## Commands

* `groups uid`  
	*Checks the groups of the specified user
	
	example:
		* `groups theron`
		* `theron : theron root sudo kvm rampage zandronum steam chaoscore libvirt



* `usermod [options] uid`
	*The usermod command modifies the system account files to reflect the changes that are specified on the command


#### Account disabling /  expiration
######  $\quad$ e, --expiredate EXPIRE_DATE
$\quad$ $\quad$ The date on which the user account will be disabled. The date is specifietd in the format YYYY-MM-DD.
$\quad$ $\quad$ An empty EXPIRE_DATE argument will disable the expiration of the account.

           This option requires a /etc/shadow file. A /etc/shadow entry will be created if there were none.

       -f, --inactive INACTIVE
           The number of days after a password expires until the account is permanently disabled.

           A value of 0 disables the account as soon as the password has expired, and a value of -1 disables the
           feature.

           This option requires a /etc/shadow file. A /etc/shadow entry will be created if there were none.
	Parameters:
	-  `-a, --append
	   Add the user to the supplementary group (s). Use only with the -G option.
	- -d, --home HOME_DIR
	   The user's new login directory.
		If the -m option is given, the contents of the current home directory will be moved to the new home
	   directory, which is created if it does not already exist.

	Example:
		*sudo usermod -aG groupname username*
	  