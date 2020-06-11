# csv-cleaner-docs-introduction

Simple cli (command line interface) open source .csv (comma separated values) cleaner. I use it for preparing USAA .csv files for conversion to .ofx files for import to financial software like Quicken, Quickbooks, or open source Gnucash (https://gnucash.org). 

## Requirements:

* Bash (or equivalent) 
* Sed
* csv2ofx (optional - requires python - 'pip install csv2ofx' - instructions here - https://github.com/reubano/csv2ofx)

Mapping file(s) are included for csv2ofx, e.g mapping/usaa.py. I add a header to all my .csv files for manual editing and clarity. If you don't want to add a header, edit header="YES" in config.conf and update your copy of the the mapping file accordingly. Installing mapping files are covered at the csv2ofx site. (RTFM)
