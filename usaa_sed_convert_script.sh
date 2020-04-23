#!/bin/sh

# Debit amounts are always positive, credit amounts are always negative.

# Header: Date,Payee,Account,Amount. Remove unneccessary fluff.

# Check for target file, rename/restore original as needed
if [[ $1 ]]; then
   . "${BASH_SOURCE%/*}/config.conf"

   if ! [[ -f $1.orig ]]; then
      echo "Backing up original file $1"
      cp $1 $1.orig
   else
      echo "Restoring original file $1"
      cp $1.orig $1
   fi

   # Insert CSV headers
   if [[ $SHOW_HEADERS ]]; then
      sed -i '' '1i\ 
      Date,Payee,Account,Amount
      ' $1
   fi

   # Make versioned substitutions
   if ! [ -d $VERSIONS ]; then
      mkdir $VERSIONS 
   fi
   sed "s/posted,,//g" $1 > $VERSIONS/01_remove_posted_$1
   sed 's/,,/,/g' $VERSIONS/01_remove_posted_$1 > $VERSIONS/02_dbl_comma_$1
   sed "s/,--/,+/g" $VERSIONS/02_dbl_comma_$1 > $VERSIONS/03_remove--$1
   sed "s/,-/,/g" $VERSIONS/03_remove--$1 > $VERSIONS/04_remove-_$1
   sed "s/,+/,-/g" $VERSIONS/04_remove-_$1 > final_$1
   
   # Perform final in place substitutions read from usermap.txt
   if [ -e usermap.txt ]; then # If usermap.txt file exists locally, use it.
      sed -i '' -f usermap.txt final_$1
   fi

   #sed "s/,-.*/&,/g" # unused 
   #csv2ofx -m usaa final_$1 final_$1.ofx # uncomment if you have one .csv file. I cat mine.
 
else

   echo "\n     FAIL - You must provide a target file, no stdin. Eejit.\n"

fi
