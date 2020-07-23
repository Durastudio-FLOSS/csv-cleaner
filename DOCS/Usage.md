# csv-cleaner-docs-usage

## Usage:

Run csv-cleaner.sh the first time with full path. Then use the symlink in your working directory. When you run 'clean' it will remove all working files and links. It does not remove your custom usermap.txt.

* You must edit config.conf and usermap.txt. 
* Defaults copy usermap.sample to usermap.txt in your working directiory. Additional sed substitution commands are listed here. eg s/entry-you-don't-want/new-entry/g - one comand per line. See Sed manual on '-f script-file' command option. https://www.gnu.org/software/sed/manual/sed.html#sed-commands-list
* Cat individual output files (remove duplicate headers) into one .csv master file.
* Convert file(s) using the csv2ofx command listed in the script. If you are lucky enough to have one .csv file for all accounts, uncomment the csv2ofx command and let the script make your .ofx file.
* Test your .ofx import on a dummy company.
* Make sure your .csv date ranges are correct as most import tools do not check for duplicate transactions. There's a provision for date ranges using csv2ofx. (RTFM)

If it works, hurray! Share your work. Save us all some time. :)
