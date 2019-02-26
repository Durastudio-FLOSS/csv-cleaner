# csv-cleaner

Simple cli (command line interface) open source .csv (comma separated values) cleaner. I use it for preparing USAA .csv files for conversion to .ofx files for import to financial software like Quicken, Quickbooks, or open source Gnucash (https://gnucash.org). 

Requirements:

* Bash (or equivalent) 
* Sed
* csv2ofx (optional - requires python - 'pip install csv2ofx' - instructions here - https://github.com/reubano/csv2ofx)

Mapping file(s) are included for csv2ofx, e.g mapping/usaa.py. I add a header to all my .csv files for manual editing and clarity. If you don't want to add a header, remove header insert line from your copy of the script and change your copy of the the mapping accordingly.

# Usage:

Copy, rename, edit to taste, and run the shell script for each individual account .csv file. Cat those files into one .csv master file. Convert that file using the commented csv2ofx command listed in the script. If you are lucky enough to have  one .csv file for all accounts, uncomment the csv2ofx command and let the script make your .ofx file. Test your .ofx import on dummy company. Make sure your .csv date ranges are correct as most import tools do not check for duplicate transactions.

If it works, hurray! Share your work. Save us all some time. :)
