#!/bin/bash
# Script to retrieve books from ftp server

server="comecloserto.me"
user="anonymous"
passwd=" "

month=$(date | awk '{print $3}') # current month
dates=() # array of dates

#echo "[*] Getting book listing..."

# query the ftp server for a listing of books, store in a file called listing
ftp -n $server > listing << ENDSCRIPT
quote USER $user 
quote PASS $passwd 
ls
bye
ENDSCRIPT

#echo "[*] Finding newest book..."

# go through all the books in the directory
while read LINE; do
    tmpMonth=$(echo $LINE | cut -d " " -f 6)
    # if month is equal to current month, check date
    if [[ $tmpMonth == $month ]]; then
        # store the date the book was added
        dates+=( `echo $LINE | cut -d " " -f 7`)
        # store the whole line of the newer book in a new file
        echo $LINE >> tmp.listing
    fi
done < listing

#sort the array of dates
sorted=($(for t in "${dates[@]}"; do echo "$t"; done | sort -rn))
new=$(echo ${sorted[0]}) # newest date a book was added

# find what line number the title of the new book is on
for i in "${!dates[@]}"; do
    if [[ "${dates[$i]}" == $new ]]; then
        num=$i
        let num=num+1
    fi
done

# get the name of the new book
file=$(sed -n "${num}p" tmp.listing | cut -d " " -f 9-)
rm tmp.listing

#echo "[*] Found $file"
#echo "[*] Retrieving book..."

# query the ftp server for the neweset book
ftp -n $server << ENDSCRIPT
quote USER $user
quote PASS $passwd
binary
get "$file"
bye
ENDSCRIPT

mv "/root/$file" /root/Books
#echo "[*] Complete"
