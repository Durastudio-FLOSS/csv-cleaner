#!/bin/sh

# NOTE: Debit amounts are always positive, credit amounts are always negative.
# Header: Only need Date,Payee,Account,Amount. Remove unneccessary chaff.

# Check for target file, rename/restore original as needed.
if [[ -e $1 || $1 == "clean" || $1 == "archive" || -e working_copy.csv ]]; then
   
   # Update $1 for working script link
   if ! [[ "$1" ]]; then
      ORIGINAL="working_copy.csv"
   elif [[ $1 != "clean" || $1 != "archive" ]]; then
      ORIGINAL="$1"
   fi

   # Check that log dir exists in working dir, create if not.
   if ! [ -d log ]; then
      mkdir -v log
   fi

   # Source settings.
   . "${BASH_SOURCE%/*}/config.conf"
   echo "- NOTICE - Sourced config.conf" > log/$LOGFILENAME

   if [[ $SYMLINKSRC ]] && ! [[ -e csv-cleaner ]]; then
      ln -s "$0" csv-cleaner
      echo "Created symlink to $0" >> log/$LOGFILENAME
      ln -s "${BASH_SOURCE%/*}/config.conf"
      echo "- TASK - Created symlink to config.conf" >> log/$LOGFILENAME
   fi

   if [[ $COPY_USERMAP_SAMPLE ]] && ! [[ -e usermap.txt ]]; then
      cp "${BASH_SOURCE%/*}/usermap.sample usermap.txt"
      echo "- TASK - Copied usermap.sample to usermap.txt" >> log/$LOGFILENAME
   fi

   if ! [[ "$(basename "$1")" == "$1" ]]; then
      ln -s "$1" $(basename "$1")
      echo "- TASK - Created symlink to $1" >> log/$LOGFILENAME
   fi

   # Check if in versions dir.
   if [[ "$(basename "$PWD")" == "versions" ]]; then
      echo "- ERROR - You are in the versions directory, move up to your working directory." 1>&2
      exit 1
   fi

# Check if in log dir.
   if [[ "$(basename "$PWD")" == "log" ]]; then
      echo "- ERROR - You are in the logging directory, move up to your working directory." 1>&2
      exit 1
   fi

   if [[ "$1" == "clean" ]] && [[ ! -e working_copy.csv ]]; then
      echo "- TASK - Starting cleanup. Removing files and dir(s)."
      rm -v cleaned*
      rm -v versions/*  
      rm -dv versions
      rm -v log/*
      rm -dv log
      rm -v .orig_fname.txt
      if [[ -L "csv-cleaner" ]]; then
         rm "csv-cleaner"
         rm "config.conf"
      fi
      echo "- TASK - Cleanup complete."
      exit 0
   elif [[ "$1" == "clean" ]]; then
      echo "- ERROR - Run 'archive' before 'clean.'"
      exit 0
   fi
   
   if [[ "$1" == "archive" ]]; then
      echo "- TASK - Starting archive. Copying files and dir(s)..." >> log/$LOGFILENAME
      ARCHIVE="archive-$(date +%d%b%Y_%T)"
      mkdir -v $ARCHIVE 
      cp -v cleaned* $ARCHIVE
      cp -Rv versions $ARCHIVE
      cp -Rv log $ARCHIVE
      orig_fname=$(<.orig_fname.txt)
      echo "- TASK - Restoring original file: $orig_fname" >> log/$LOGFILENAME
      cp -v working_copy.csv $orig_fname
      rm -v working_copy.csv
      cp cleaned_$ORIGINAL cleaned_$orig_fname
      echo "- TASK - Archive to $ARCHIVE complete. Run 'clean' to remove working files." >> log/$LOGFILENAME
      exit 0
   fi

   if ! [[ -e working_copy.csv && $1 != "archive" ]]; then
      echo "- TASK - Backing up original file $1 to working_copy.csv" >> log/$LOGFILENAME
      cp $1 working_copy.csv
      echo "$1" > .orig_fname.txt 
   else
      echo "- NOTICE - Working files found, nothing to see here, move on." >> log/$LOGFILENAME
   fi

   # Insert CSV headers.
   if [[ $SHOW_HEADERS ]]; then
sed -i '' '1i\
Date,Payee,Account,Amount
' $1
   fi
   
   # Check that versions dir exists in working dir, create if not.
   if ! [ -d versions ]; then
      mkdir -v versions 
   fi

   # Perform basic housekeeping.
   echo "- TASK - Cleaning $ORIGINAL" >> log/$LOGFILENAME
   sed "s/posted,,//g" $ORIGINAL > versions/01_remove_posted_$ORIGINAL
   sed 's/,,/,/g' versions/01_remove_posted_$ORIGINAL > versions/02_dbl_comma_$ORIGINAL
   sed "s/,--/,+/g" versions/02_dbl_comma_$ORIGINAL > versions/03_remove--$ORIGINAL
   sed "s/,-/,/g" versions/03_remove--$ORIGINAL > versions/04_remove-_$ORIGINAL
   sed "s/,+/,-/g" versions/04_remove-_$ORIGINAL > cleaned_$ORIGINAL
   
   # Perform final in place substitutions read from usermap.txt.
   if [ -e usermap.txt ]; then # If usermap.txt file exists locally, use it.
      echo "- TASK - Applying usermap.txt commands." >> log/$LOGFILENAME
      sed -i '' -f usermap.txt cleaned_$ORIGINAL
   fi

   #sed "s/,-.*/&,/g" # unused 

   # Uncomment if you have one .csv file.
   #csv2ofx -m usaa final_$1 final_$1.ofx

   echo "- NOTICE - Csv Cleaner complete." >> log/$LOGFILENAME
   cat log/$LOGFILENAME

else

   echo "\n- USAGE - You must provide a target file and it must exist, no stdin. Eejit.\n" 1>&2
   exit 1

fi
