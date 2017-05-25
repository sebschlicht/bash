# bash Collection

Welcome to my collection of BASH scripts.
This is what you can find in this repository:

* [FLOG](flog.sh): Converts a all FLAC audio files inside a directory to the smaller OGG format.  
  **Example:** `flog ~/Music/Albums/System/Toxicity`

* [XPower](https://github.com/sebschlicht/xpower) (own project now): Swaps the power settings when the power plug is added/removed, to allow different brightness and lock timeout settings depending on the AC status. Comes with an installer.

* [NAS Backup Script](https://github.com/sebschlicht/backupnas) (own project now): Backup directories to a local or remote location such as a Samba server or a RaspberryPi via SSH. Comes with an installer.

* [PDFShrink](pdfshrink.sh): Shrinks a PDF file in order to reduce its size using GhostScript. Several quality levels supported.  
  **Example:** `pdfshrink -l high myDocument.pdf myDocument_shrinkedHQ.pdf`

* [Template](template.sh): Well, this is actually not a script but the template that I'm using for new BASH scripts.  It provides you with an overall code structure and contains code to handle both command line parameters and arguments.

Each script is supporting at least the `-h` switch to guide you on its usage including possible options.

On a code basis, they're all well documented. Feel free to improve and extend.
