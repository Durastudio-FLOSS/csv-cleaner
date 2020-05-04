#!/bin/sh

# NOTE: Debit amounts are always positive, credit amounts are always negative.
# Header: Only need Date,Payee,Account,Amount. Remove unneccessary chaff.

# Check for target file, rename/restore original as needed.
if [[ -e $1 || $1 == "clean" || $1 == "archive" ]]; then
   
   # Check that log dir exists in working dir, create if not.
   if ! [ -d log ]; then
      mkdir -v log
   fi

   # Source settings.
   . "${BASH_SOURCE%/*}/config.conf"
   echo "Sourced config.conf" > log/$LOGFILENAME

   if [[ $SYMLINKSRC ]] && ! [[ -e csv-cleaner ]]; then
      ln -s "$0" csv-cleaner
      ln -s "${BASH_SOURCE%/*}/config.conf"
   fi

   if [[ $COPY_USERMAP_SAMPLE ]] && ! [[ -e usermap.txt ]]; then
      cp "${BASH_SOURCE%/*}/usermap.sample usermap.txt"
   fi

   if ! [[ "$(basename "$1")" == "$1" ]]; then
      ln -s "$1" $(basename "$1")
   fi

   # Check if in versions dir.
   if [[ "$(basename "$PWD")" == "versions" ]]; then
      #echo "$(basename "$PWD") - versions" # uncomment for testing
      echo "\n- ERROR - You are in the versions directory, move up to your working directory.\n" 1>&2
      exit 1
   fi

# Check if in log dir.
   if [[ "$(basename "$PWD")" == "log" ]]; then
      echo "\n- ERROR - You are in the logging directory, move up to your working directory.\n" 1>&2
      exit 1
   fi

   if [[ "$1" == "clean" ]]; then
      echo "\n- TASK - Starting cleanup. Removing files and dir(s)...\n"
      rm -v final*
      rm -v versions/*  
      rm -dv versions
      rm -v log/*
      rm -dv log
      if [[ -L "csv-cleaner" ]]; then
         rm "csv-cleaner"
         rm "config.conf"
      fi
      echo "\n- TASK - Cleanup complete.\n"
      exit 0
   fi
   
   if [[ "$1" == "archive" ]]; then
      echo "\n- TASK - Starting archive. Copying files and dir(s)...\n"
      ARCHIVE="archive-$(date +%d%b%Y_%T)"
      mkdir -v $ARCHIVE 
      cp -v final* $ARCHIVE
      cp -Rv versions $ARCHIVE
      cp -Rv log $ARCHIVE
      echo "\n- TASK - Archive to $ARCHIVE complete. Run 'clean' to remove working files.\n"
      exit 0
   fi

   if ! [[ -f versions/$(basename "$1").orig ]]; then
      echo "Backing up original file $1"
      cp $1 versions/$(basename "$1").orig
   else
      echo "Restoring original file $1"
      cp versions/$(basename "$1").orig $1
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
   sed "s/posted,,//g" $1 > versions/01_remove_posted_$(basename "$1")
   sed 's/,,/,/g' versions/01_remove_posted_$(basename "$1") > versions/02_dbl_comma_$(basename "$1")
   sed "s/,--/,+/g" versions/02_dbl_comma_$(basename "$1") > versions/03_remove--$(basename "$1")
   sed "s/,-/,/g" versions/03_remove--$(basename "$1") > versions/04_remove-_$(basename "$1")
   sed "s/,+/,-/g" versions/04_remove-_$(basename "$1") > final_$(basename "$1")
   
   # Perform final in place substitutions read from usermap.txt.
   if [ -e usermap.txt ]; then # If usermap.txt file exists locally, use it.
      sed -i '' -f usermap.txt final_$(basename "$1")
   fi

   #sed "s/,-.*/&,/g" # unused 

   # Uncomment if you have one .csv file.
   #csv2ofx -m usaa final_$1 final_$1.ofx
    
   rm -v $(basename "$1")

else

   echo "\n- USAGE - You must provide a target file and it must exist, no stdin. Eejit.\n" 1>&2
   exit 1

fi
