#!/bin/sh

# NOTE: Debit amounts are always positive, credit amounts are always negative.
# Header: Only need Date,Payee,Account,Amount. Remove unneccessary chaff.

# Check for target file, rename/restore original as needed.
if [[ -e $1 || $1 == "clean" || $1 == "archive" || -e working_copy.csv ]]; then
   
   # Update $1 for working script link
   if ! [[ "$1" ]]; then
      ORIGINAL="working_copy.csv"
   elif ! [[ $1 == "clean" || $1 == "archive" || $1 == "export" ]]; then
      ORIGINAL="$1"
   fi

   # Check that log dir exists in working dir, create if not.
   if ! [ -d log ]; then
      mkdir -v log
   fi

   # Source settings.
   . "${BASH_SOURCE%/*}/config.conf"
   echo " - TASK - Sourced config.conf" > log/$LOGFILENAME

   if [[ $SYMLINKSRC ]] && ! [[ -e csv-cleaner ]]; then
      ln -s "$0" csv-cleaner
      echo " - TASK - Created symlink to $0" >> log/$LOGFILENAME
      ln -s "${BASH_SOURCE%/*}/config.conf"
      echo " - TASK - Created symlink to config.conf" >> log/$LOGFILENAME
   fi

   if [[ $COPY_USERMAP_SAMPLE ]] && ! [[ -e usermap.txt ]]; then
      cp "${BASH_SOURCE%/*}/usermap.sample usermap.txt"
      echo " - TASK - Copied usermap.sample to usermap.txt" >> log/$LOGFILENAME
   fi

   if ! [[ "$(basename "$1")" == "$1" ]]; then
      ln -s "$1" $(basename "$1")
      echo " - TASK - Created symlink to $1" >> log/$LOGFILENAME
   fi

   # Check if in versions dir.
   if [[ "$(basename "$PWD")" == "versions" ]]; then
      #echo "$(basename "$PWD") - versions" # uncomment for testing
      echo "\n - ERROR - You are in the versions directory, move up to your working directory.\n" 1>&2
      exit 1
   fi

# Check if in log dir.
   if [[ "$(basename "$PWD")" == "log" ]]; then
      echo "\n - ERROR - You are in the logging directory, move up to your working directory.\n" 1>&2
      exit 1
   fi

   if [[ "$1" == "clean" ]]; then
      echo "\n - TASK - Starting cleanup. Removing files and dir(s)...\n"
      rm -v cleaned*
      rm -v sorted*
      rm -v versions/*  
      rm -dv versions
      rm -v log/*
      rm -dv log
      rm -v .orig_fname.txt
      if [[ -L "csv-cleaner" ]]; then
         rm "csv-cleaner"
         rm "config.conf"
      fi
      echo " - TASK - Cleanup complete."
      exit 0
   elif [[ "$1" == "clean" ]]; then
      echo " - ERROR - Run 'archive' before 'clean.'"
      exit 0
   fi
   
   if [[ "$1" == "archive" ]]; then
      echo "\n - TASK - Starting archive. Copying files and dir(s)...\n"
      ARCHIVE="archive-$(date +%d%b%Y_%T)"
      mkdir -v $ARCHIVE 
      cp -v cleaned* $ARCHIVE
      cp -Rv versions $ARCHIVE  

      # Restore original and delete working files
      orig_fname=$(<.orig_fname.txt)
      echo " - TASK - Restoring original file: $orig_fname" >> log/$LOGFILENAME
      cp -v $ORIGINAL $orig_fname
      rm -v $ORIGINAL
      rm -v working*
      
      # Export feature will pull in other sed rules for various formatting needs.
      sed s/^.*,'\([A-Za-z]* *[A-Za-z]*[\/*\:* \& *]*[A-Za-z]* *[A-Za-z]*\)',-*[0-9]*.[0-9]*$/\\1/g cleaned_$orig_fname > accounts_$orig_fname  # Export accounts

      echo "\n - TASK - Exporting in $EXPORT_NUM_COLS columns format.\n"
      if [[ $EXPORT_NUM_COLS == 2 ]]; then
         sed s/,'\([0-9]*.[0-9]*\)'$/,\\1,/g cleaned_$orig_fname > export_$orig_fname  # Add column
         sed -i "" s/,'\(-[0-9]*.[0-9]*\)'$/,,\\1/g export_$orig_fname # Add column, move data

         if [[ $CHANGE_SIGN == "YES" ]]; then
            sed -i "" s/,-'\([0-9]*.[0-9]*\)'$/,\\1/g export_$orig_fname # Change sign of credits
         fi

      else
         cp -v cleaned_$orig_fname export_$orig_fname
      fi

      cp -Rv log $ARCHIVE
      echo "\n - TASK - Archive to $ARCHIVE complete. Run 'clean' to remove working files.\n"
      exit 0
   fi

   if ! [[ -e working_copy.csv && $1 != "archive" ]]; then
      echo " - TASK - Backing up original file $1 to working_copy.csv" >> log/$LOGFILENAME
      cp $1 working_copy.csv
      echo "$1" > .orig_fname.txt 
   else
      echo " - NOTICE - Working files found, nothing to see here, move on." >> log/$LOGFILENAME
   fi

   # Insert CSV headers.
#   if [[ $SHOW_HEADERS == "YES" ]]; then
#sed -i '' '1i\
#Date,Payee,Account,Amount
#' $1
#   fi
   
   # Check that versions dir exists in working dir, create if not.
   if ! [ -d versions ]; then
      mkdir -v versions 
   fi

   # Perform basic housekeeping.
   echo " - TASK - Cleaning $ORIGINAL" >> log/$LOGFILENAME
   sed "s/posted,,//g" $ORIGINAL > versions/01_remove_posted_$ORIGINAL
   sed 's/,,/,/g' versions/01_remove_posted_$ORIGINAL > versions/02_dbl_comma_$ORIGINAL
   sed "s/,--/,+/g" versions/02_dbl_comma_$ORIGINAL > versions/03_remove--$ORIGINAL
   sed "s/,- /,/g" versions/03_remove--$ORIGINAL > versions/04_remove-_$ORIGINAL
   sed "s/,+/,-/g" versions/04_remove-_$ORIGINAL > cleaned_$ORIGINAL
   
   # Perform final in place substitutions read from usermap.txt.
   if [ -e usermap.txt ]; then # If usermap.txt file exists locally, use it.
      echo " - TASK - Applying usermap.txt commands." >> log/$LOGFILENAME
      sed -i '' -f usermap.txt cleaned_$ORIGINAL
   fi

   # Sort and Copy
   sed -i "" /Date,Payee,Account,Amount/d # remove header line(s) if present
   echo " - TASK - Sorting file cleaned_$ORIGINAL to sorted_$ORIGINAL >> log/$LOGFILENAME
   sort -t , -k 1b cleaned_$ORIGINAL > sorted_$ORIGINAL
   cp -v sorted_$ORIGINAL cleaned_$orig_fname

   # Uncomment if you have one .csv file. # Todo make from config
   #csv2ofx -m usaa final_$1 final_$1.ofx

   echo " - NOTICE - Csv Cleaner complete." >> log/$LOGFILENAME
   cat log/$LOGFILENAME

else

   echo "\n - USAGE - You must provide a target file and it must exist, no stdin. Eejit.\n" 1>&2
   exit 1

fi
