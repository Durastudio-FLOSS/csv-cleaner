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

   # Check if in versions dir.
   if [[ "$(basename "$PWD")" == "$VERSIONS" ]]; then
      #echo "$(basename "$PWD") - $VERSIONS" # uncomment for testing
      echo "\n- ERROR - You are in the $VERSIONS directory, move up to your working directory.\n" 1>&2
      exit 1
   fi

# Check if in log dir.
   if [[ "$(basename "$PWD")" == "log" ]]; then
      echo "\n- ERROR - You are in the logging directory, move up to your working directory.\n" 1>&2
      exit 1
   fi

   if [[ "$1" == "clean" ]]; then
      echo "\n- TASK - Starting cleanup. Removing files and dir(s)...\n"
      rm -v *.orig final*
      rm -v versions/*  
      rm -dv $VERSIONS
      rm -v log/*
      rm -dv log
      echo "\n- TASK - Cleanup complete.\n"
      exit 0
   fi
   
   if [[ "$1" == "archive" ]]; then
      echo "\n- TASK - Starting archive. Copying files and dir(s)...\n"
      ARCHIVE="archive-$(date +%d%b%Y_%T)"
      mkdir -v $ARCHIVE 
      cp -v *.orig final* $ARCHIVE
      cp -Rv versions $ARCHIVE
      cp -Rv log $ARCHIVE
      echo "\n- TASK - Archive to $ARCHIVE complete. Run 'clean' to remove working files.\n"
      exit 0
   fi

   if ! [[ -f $1.orig ]]; then
      echo "Backing up original file $1"
      cp $1 $1.orig
   else
      echo "Restoring original file $1"
      cp $1.orig $1
   fi

   # Insert CSV headers.
   if [[ $SHOW_HEADERS ]]; then
      sed -i '' '1i\ 
      Date,Payee,Account,Amount
      ' $1
   fi
   
   # Check that $VERSIONS dir exists in working dir, create if not.
   if ! [ -d $VERSIONS ]; then
      mkdir -v $VERSIONS 
   fi

   # Perform basic housekeeping.
   sed "s/posted,,//g" $1 > $VERSIONS/01_remove_posted_$1
   sed 's/,,/,/g' $VERSIONS/01_remove_posted_$1 > $VERSIONS/02_dbl_comma_$1
   sed "s/,--/,+/g" $VERSIONS/02_dbl_comma_$1 > $VERSIONS/03_remove--$1
   sed "s/,-/,/g" $VERSIONS/03_remove--$1 > $VERSIONS/04_remove-_$1
   sed "s/,+/,-/g" $VERSIONS/04_remove-_$1 > final_$1
   
   # Perform final in place substitutions read from usermap.txt.
   if [ -e usermap.txt ]; then # If usermap.txt file exists locally, use it.
      sed -i '' -f usermap.txt final_$1
   fi

   #sed "s/,-.*/&,/g" # unused 

   # Uncomment if you have one .csv file.
   #csv2ofx -m usaa final_$1 final_$1.ofx

else

   echo "\n- USAGE - You must provide a target file and it must exist, no stdin. Eejit.\n" 1>&2
   exit 1

fi
