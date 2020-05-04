# csv-cleaner

Simple cli (command line interface) open source .csv (comma separated values) cleaner. I use it for preparing USAA .csv files for conversion to .ofx files for import to financial software like Quicken, Quickbooks, or open source Gnucash (https://gnucash.org). 

## Requirements:

* Bash (or equivalent) 
* Sed
* csv2ofx (optional - requires python - 'pip install csv2ofx' - instructions here - https://github.com/reubano/csv2ofx)

Mapping file(s) are included for csv2ofx, e.g mapping/usaa.py. I add a header to all my .csv files for manual editing and clarity. If you don't want to add a header, edit header="YES" in config.conf and update your copy of the the mapping file accordingly. Installing mapping files are covered at the csv2ofx site. (RTFM)

## Usage:

Run csv-cleaner.sh the first time with full path. Then use the symlink in your working directory. When you run 'clean' it will remove all working files and links.

* You must edit script to use. 
* Additional sed substitution commands are listed in usermap.txt. eg s/entry-you-don't-want/new-entry/g - one comand per line. See Sed manual on '-f script-file' command option. https://www.gnu.org/software/sed/manual/sed.html#sed-commands-list
* Cat individual output files (remove duplicate headers) into one .csv master file.
* Convert file(s) using the csv2ofx command listed in the script. If you are lucky enough to have one .csv file for all accounts, uncomment the csv2ofx command and let the script make your .ofx file.
* Test your .ofx import on a dummy company.
* Make sure your .csv date ranges are correct as most import tools do not check for duplicate transactions. There's a provision for date ranges using cvs2ofx. (RTFM)

If it works, hurray! Share your work. Save us all some time. :)

## Todo

* Add stderr bash conventions and error checking
* Git project settings
* Automation - find symlinks to self and act on raw data. eg monthly reporting.
* Prep for .ofx import - Cat individual account files and remove duplicate headers if present
* Documentation - How to use
* Substitution widget, append to command list.
