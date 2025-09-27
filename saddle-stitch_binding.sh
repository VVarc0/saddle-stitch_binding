#! /bin/bash

#
# Created by Marco Fienili & Nicola Battistoni
#
# This script uses pdfjam for split an input PDF into more sub-PDFS called "decks"
# This script calculate numbers of pages, sheets and decks needed



# VARIABLES

# The input pdf
PDF_FILE=$1
#
TOTAL_PAGES_NUM=$(pdfinfo ${PDF_FILE} | grep "Pages:" | sed 's/Pages:[ \t]*//')
# Max number of sheets per single deck
MAX_SHEETS_PER_DECK=20
# How many pages will be print on one sheet face
PAGES_PER_SHEET_FACE=2 
# Sheets have just two faces
PAGES_PER_SHEET=$(( PAGES_PER_SHEET_FACE * 2 )) 
# How many sheets are needed for the entire pdf
PAGES_REST=$(( TOTAL_PAGES_NUM % PAGES_PER_SHEET ))
# Math trick for rounding
SHEETS_NUM=$(( (TOTAL_PAGES_NUM - PAGES_REST ) / PAGES_PER_SHEET + (PAGES_REST == 0 ? 0 : 1) ))
# Number of blank pages that will remain at the end
# Number of decks
DECKS_NUM=$(( SHEETS_NUM / MAX_SHEETS_PER_DECK))

# This variable says two things:
# How many sheets rests form the division
# How many decks will recive one more sheet
#
# If numbers of decks is 0: EXTRA_SHEETS = SHEETS_NUM
# Else: EXTRA_SHEETS = (SCHEETS_NUM % DECKS_NUM)
EXTRA_SHEETS=$(( (DECKS_NUM == 0 ? SHEETS_NUM : SHEETS_NUM % DECKS_NUM) ))

# If there are extra sheet make a new deck
[[ EXTRA_SHEETS != 0 ]] && (( DECKS_NUM=$DECKS_NUM + 1 ))
#
# We used bash embedded if for rounding the value of SHEETS_PER_DECK
# SHEETS_PER_DECK = SHEETS_NUM / DECKS_NUM
# If EXTRA_SHEETS = 0: add 0 to calculation
# Else: add 1 to calculation
SHEETS_PER_DECK=$(( SHEETS_NUM / DECKS_NUM + (EXTRA_SHEETS == 0 ? 0 : 1) ))
# Number of pages for single deck
PAGES_PER_DECK=$(( SHEETS_PER_DECK * PAGES_PER_SHEET ))
# It's the same number of deck will take another sheet
EXTRA_PAGES=$(( TOTAL_PAGES_NUM - PAGES_PER_DECK * ( DECKS_NUM - 1 ) ))

# Just output for the user
echo "INPUT PDF: ${TOTAL_PAGES_NUM} pages"
echo "YOU WANT MAXIMUM ${MAX_SHEETS_PER_DECK} SHEETS PER DECK"
echo "Rounded up number of needed sheets: $SHEETS_NUM"
echo "Decks: $DECKS_NUM"
echo "All $DECKS_NUM decks: $SHEETS_PER_DECK sheets each"

# If $EXTRA_SHEETS is more then 0:
# Inform the user that first $EXTRA_SHEETS decks will take one more sheet
[[ $EXTRA_SHEETS > 0 ]] && echo "The last deck will contain $(( (EXTRA_PAGES / PAGES_PER_SHEET) + 1 )) sheets"


# This variable will be used as start-index for splitting a sub PDF
# Will be increased of $PAGES_PER_DECK times and used as start-index for splitting the next sub PDF
# Assign the number of the firs page (PDFs start from 1)
tmp_n=1 

# For first $EXTRA_SHEETS decks
for ((i = 0; i < $DECKS_NUM; i++)); do
    # echo "$tmp_n-$(( tmp_n + PAGES_PER_SHEET))"
    if [[ $i == $(( DECKS_NUM - 1 )) ]]; then
        pdfjam --quiet "$PDF_FILE" "$tmp_n-$TOTAL_PAGES_NUM" -o "o$tmp_n-$TOTAL_PAGES_NUM.pdf"
    else
        pdfjam --quiet "$PDF_FILE" "$tmp_n-$(( tmp_n + PAGES_PER_DECK - 1 ))" -o "o$tmp_n-$(( tmp_n + PAGES_PER_DECK - 1 )).pdf"
        tmp_n=$(( tmp_n + PAGES_PER_DECK)) # the first page of the next deck
    fi
done