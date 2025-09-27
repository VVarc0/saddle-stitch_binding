#! /bin/bash

# 
# Created by Marco Fienili
# 
# This script will take a PDF in input, for reordering it in a way useful for saddle-stitch bookbinding
# From the input PDF pages, it will make a list of temporary PDFs with the scheme: 1,N ; 2,N-1 ; 3,N-2 ;...
# This script will make an output file named "output.pdf".
# It will not override the input file, if the input file isn't named "output.pdf"

# The input PDF
PDF_FILE=$1
# The output file
OUTPUT_FILE="./output.pdf"
# Directory where putting temporary files
TMP_DIR="./tmp"
# Input PDF's number of pages 
TOTAL_PAGES_NUM=$(pdfinfo ${PDF_FILE} | grep "Pages:" | sed 's/Pages:[ \t]*//')

# If ./tmp directory doesn't exist make it and inform the user
[[ ! -d "$TMP_DIR" ]] && mkdir ${TMP_DIR} && echo "Temporary directory created"

# Indexing variables
i=1 # This indexes the first half of the deck (form the first page)
j=$TOTAL_PAGES_NUM # This indexes the second half of the deck (form the last page)
tmp_list=() # This array will get all temporary files and will be filled in order

# The format for naming tmp files is: tmp_i,j.pdf


# Just some informative output: the script is running
echo "Making temporary files and ordering pages."


# IF THE NUMBER OF PAGES IS ODD:
# then make the first temporary PDF with the first page (first page of the deck) 
# with the first page of the input file
# and make the second page (last page of the deck) blank 
if [[ $(( (TOTAL_PAGES_NUM / 4) % 2 )) != 0 ]]; then
    # Create a pdf with the second page as a blank page
    pdfjam --quiet "$PDF_FILE" "${i},{}" -o "${TMP_DIR}/tmp_${i},{}.pdf"
    # Add to list of temporary files the file just created by pdfjam
    tmp_list+=("${TMP_DIR}/tmp_${i},{}.pdf")
    # Increase i by one, so the for loop will start with i=2
    i=$(( $i + 1 )) 
fi
 
# DO IT IN ANY CASE

# For loop variable ( 'i' and 'j' ) are already defined
# i condition is rounded up, with the math trick ((numerator + denominator -1) / denominator)
for (( ; i<=$(( (TOTAL_PAGES_NUM + 2 -1) / 2 )) && j>=(( TOTAL_PAGES_NUM / 2 )) ; i++, j-- )); do
    # Create a two-pages tmp pdf from input file, with first index i as first page and index j as second
    pdfjam --quiet "$PDF_FILE" "$i,$j" -o "${TMP_DIR}/tmp_${i},${j}.pdf"
    # Add to list of temporary files the file just created by pdfjam
    tmp_list+=("${TMP_DIR}/tmp_${i},${j}.pdf")
done

# Just some informative output: the script is still running
echo "Jointing all PDFs in one..."
# Executing silenced pdfjam for jointing all .PDFs in just one
pdfjam --quiet "${tmp_list[@]}" -o "${OUTPUT_FILE}"
# Removing any temporary file and inform the user
rm -r ${TMP_DIR} && echo "All temporary files are removed"
# Just some informative output
echo "Done."

exit 0