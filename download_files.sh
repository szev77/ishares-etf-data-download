#!/bin/bash

for f in ./blackrock_ishares/*.txt
do
	echo "*********************"
	echo "File: $f" 
	echo "+++++++++++++++++++++"
	while IFS=, read number name code; do
  		OUTPUTPATH="downloaded_files/${code}_${number}_${name}"
  		rm -f "${OUTPUTPATH}.*"
  		wget -c "https://www.blackrock.com/ca/individual/en/$number/fund-download.dl" -O "${OUTPUTPATH}.xls"
  		cat "${OUTPUTPATH}.xls" | perl -0777 -pe 's#</Style>#</ss:Style>#sg' > "${OUTPUTPATH}2.xls"
  		ssconvert -S "${OUTPUTPATH}2.xls" "${OUTPUTPATH}.csv"
  		
  		for CSVFILE in ${OUTPUTPATH}.csv.*; 
  		do
  			CSVFILE_FINAL=$(sed 's/.\{2\}$//' <<< "${CSVFILE}")
  			# https://stackoverflow.com/questions/11287861/how-to-check-if-a-file-contains-a-specific-string-using-bash
  			grep -iq '^"as of"' "${CSVFILE}"; [ $? -eq 0 ] && mv "${CSVFILE}" "${CSVFILE_FINAL}"|| rm -f "${CSVFILE}"
  		done;

  		rm -f "${OUTPUTPATH}2.xls"
	done <"$f"
	echo "---------------------"
	echo ""
done