#!/bin/sh

# NOTE: Debit amounts are always positive, credit amounts are always negative.
# Header: Only need Date,Payee,Account,Amount. Remove unneccessary chaff.

# Check for target file, rename/restore original as needed.
if [[ -e $1 ]]; then
   # Source settings.
   . "${BASH_SOURCE%/*}/config.conf"

   # Check if in versions dir move up and execute.
   if [[ "$(basename "$PWD")" == "$VERSIONS" ]]; then
      #echo "$(basename "$PWD") - $VERSIONS" # uncomment for testing
      echo "\n- ERROR - You are in the $VERSIONS directory, move up to your working directory.\n" 1>&2
      exit 1
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
      mkdir $VERSIONS 
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
