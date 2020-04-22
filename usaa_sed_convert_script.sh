#!/bin/sh

# Debit amounts are always positive, credit amounts are always negative.

# Header: Date,Payee,Account,Amount. Remove unneccessary fluff.

# Check for target file, rename/restore original as needed
if [ $1 ]; then

   if ! [ -f $1.orig ]; then

      echo "Backing up original file $1"
      cp $1 $1.orig

   else
      echo "Restoring original file $1"
      cp $1.orig $1

   fi

   # Insert CSV headers
   sed -i '' '1i\ 
   Date,Payee,Account,Amount
   ' $1

   # Make versioned substitutions 
   sed "s/posted,,//g" $1 > 01_remove_posted_$1
   sed 's/,,/,/g' 01_remove_posted_$1 > 02_dbl_comma_$1
   sed "s/,--/,+/g" 02_dbl_comma_$1 > 03_remove--$1
   sed "s/,-/,/g" 03_remove--$1 > 04_remove-_$1
   sed "s/,+/,-/g" 04_remove-_$1 > 05_finished_$1
   sed 's/Entertainment/Online Services/g' 05_finished_$1 > 06_final_$1 # Edit this. Foreach lists possible here.
   
   # Perform final in place substitutions read from usermap.txt
   sed -i '' -f usermap.txt 06_final_$1
   
   #sed "s/,-.*/&,/g" # unused 
   #csv2ofx -m usaa 06_final_$1 07_final_$1.ofx # uncomment if you have one .csv file. I cat mine.
 
else

   echo "\n     FAIL - You must provide a target file, no stdin. Eejit.\n"

fi
