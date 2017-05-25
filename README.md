# bash Collection

Welcome to my collection of bash scripts.
This is what you can find in this repository:

* [backup.sh](backup.sh): Backup directories to a local or remote location such as a Samba server

## Backup Script

(TODO) remove to a wiki page

The backup script can backup directories and files from one location to another using `rsync` under the hood.
It allows to define one or multiple locations along with their backup destinations, supports file exclusion patterns (naturally supported by *rsync*), mounting paths and prompting for credentials.

The script is intended to backup your documents, music, pictures, aso. to a NAS, for example a Samba server running on a Raspberry Pi, without having to store your credentials on disc.
You can create profiles that store all the information necessary for a user's backups.

To get out how to use that script, use the `-h` option or have a look at the script and profile examples below.

### Examples

* backup all your folders using a profile: `smbb.sh -p resources/.smbb-all.properties`
* backup a single folder to a locally mounted, remote location: `smbb.sh /home/user/pictures /mnt/nas.pi/backup/user/pictures`
* backup a single folder to an unmounted, remote location using a profile: `smbb.sh -p resources/.smbb-nas-pi.properties /home/user/pictures /mnt/nas.pi/backup/user/pictures`

[TODO] make SOURCE and TARGET relative if missing leading slash

### Profile

The profile is a file that sets a number of configuration options.
The following table lists all the configuration options that can be set in a profile.

Key                 | Default value | Description
------------------- | ------------- | -----------
SMBB_MAPPING_FILE   | undefined     | Path to the [mapping file](#mapping-file).
SMBB_EXCLUSION_FILE | undefined     | Path to the exclusion file (see `man rsync` for information on the file syntax).
SMBB_MOUNTPOINT     | undefined     | Path to mount on execution - if not yet mounted.
SMBB_UNMOUNT        | undefined     | Flag whether to unmount the mount point after backing up the files or not. If the value is left undefined, the mount point will be unmounted, if the script had to mount it during execution.
SMBB_SAMBA_USER     | undefined     | Name of the Samba user to use for mounting.
SMBB_DRY_RUN        | false         | Flag whether to do or dry run without making any changes or not.

#### Examples

[TODO] create below resource files, create blank resource files containing self-explanating comments

* [mount a remote Samba share using given credentials and backup multiple folders]

      SMBB_MAPPING_FILE=resources/.smbb-all.map
      SMBB_MOUNTPOINT=/mnt/nas.pi

* [mount a remote Samba share while prompting for credentials and backup a single folder]

      SMBB_MAPPING_FILE=resources/.smbb-single.map
      SMBB_MOUNTPOINT=/mnt/nas.pi
      SMBB_SAMBA_USER=user

* [backup multiple folders except for ZIP files to a local location]

      SMBB_MAPPING_FILE=resources/.smbb-all.map
      SMBB_EXCLUSION_FILE=resources/.smbb-zip.exclude

