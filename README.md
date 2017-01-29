# bash Collection

Welcome to my collection of bash scripts.
This is what you can find in this repository:

* [backup.sh](backup.sh): Backup directories to a local or remote location such as a Samba server

## Backup Script

(TODO) remove to a wiki page

The backup script can backup directories and files from one location to another using `rsync` under the hood.
It allows to define one or multiple locations along with their backup destinations, supports file exclusion patterns (naturally supported by *rsync*), mounting paths and prompting for credentials.

The script is intended to backup your documents, music, pictures, aso. to a NAS, for example a Samba server running on a Raspberry Pi, without having to store your credentials on disc.
In a mapping file, you define which directories to backup to which remote location.
When the script tries to mount the Samba share and you didn't provide the credentials in your fstab entry, it prompts for the credentials using a graphical interface.
Thus you can still trigger the script in a cronjob, even as superuser, without having to reveal your plain credentials to any attacker.
Currently, the script can only prompt for a password - the Samba user has to be specified on premise.

All the information necessary for the script to backup your files can be stored in a single profile.

### Profile file

Key                 | Description
------------------- | -----------
SMBB_MAPPING_FILE   | Path to the mapping file.
SMBB_EXCLUSION_FILE | Path to the exclusion file (see `man rsync` for information on the file syntax).
SMBB_MOUNTPOINT     | Path to mount on execution, if not yet mounted.
SMBB_AUTOMOUNT      | Flag whether necessary credentials are given in the fstab entry or not.
SMBB_SAMBA_USER     | Name of the Samba user to use for mounting.
SMBB_DRY_RUN        | Flag whether to do or dry run without making any changes or not.
