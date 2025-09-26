#! /bin/bash

# Created by Marco Fienili & Nicola Battistoni

# VARIABLES

# The input pdf
PDF_FILE=$1
#
TOTAL_PAGES_NUM=$(pdfinfo ${PDF_FILE} | grep "Pages:" | sed 's/Pages:[ \t]*//')
PAGES_PER_SHEET_FACE=2 # How many pages will be print on one sheet face
PAGES_PER_SHEET=$(( PAGES_PER_SHEET_FACE * 2 )) # Sheets have just two faces

# How many sheets are needed for the entire pdf
PAGES_REST=$(( TOTAL_PAGES_NUM % PAGES_PER_SHEET ))
# Math trick for rounding
SHEETS_NUM=$(( (TOTAL_PAGES_NUM - PAGES_REST ) / PAGES_PER_SHEET + (PAGES_REST == 0 ? 0 : 1) ))
# Number of blank pages that will remain at the end

# Max number of sheets per single deck
MAX_SHEETS_PER_DECK=20

# Number of decks
DECKS_NUM=$(( SHEETS_NUM / MAX_SHEETS_PER_DECK))
# I used the same math trick for rounding
EXTRA_SHEETS=$(( (DECKS_NUM == 0 ? SHEETS_NUM : SHEETS_NUM % DECKS_NUM) ))

[[ EXTRA_SHEETS != 0 ]] && (( DECKS_NUM=$DECKS_NUM + 1 )) 
# How many sheets in a deck
SHEETS_PER_DECK=$(( SHEETS_NUM / DECKS_NUM + (EXTRA_SHEETS == 0 ? 0 : 1) ))
# Number of sheets remained out the equal splitting
# It's the same number of deck will need another sheet

PAGES_PER_DECK=$(( SHEETS_PER_DECK * PAGES_PER_SHEET ))
EXTRA_PAGES=$(( TOTAL_PAGES_NUM - PAGES_PER_DECK * ( DECKS_NUM - 1 ) ))

echo "INPUT PDF: ${TOTAL_PAGES_NUM}"
echo "YOU WANT MAXIMUM ${MAX_SHEETS_PER_DECK} SHEETS PER DECK"
echo "Rounded number of needed sheets: $SHEETS_NUM"
echo "Pages per deck: $PAGES_PER_DECK"
echo "Just for your information: will remain $EXTRA_PAGES blank pages"
echo "Decks: $DECKS_NUM"
echo "Sheets per deck: $SHEETS_PER_DECK"

# I primi EXTRA_SHEETS mazzetti prendono un foglio in più
if [[ $EXTRA_SHEETS > 0 ]]; then
    echo "First $EXTRA_SHEETS decks: $((SHEETS_PER_DECK + 1)) sheets each | $PAGES_PER_DECK_WITH_EXTRA_SHEETS pages each"
    echo "Remaining $((DECKS_NUM - EXTRA_SHEETS)) decks: $SHEETS_PER_DECK sheets each | $PAGES_PER_DECK_WITHOUT_EXTRA_SHEETS pages each"
else
    echo "All $DECKS_NUM decks: $SHEETS_PER_DECK sheets each"
fi

# L'idea è di creare un array[di lunghezza DECKS_NUM] di indici '1-20','21-40'...
# DEVI USARE PAGE_PER_SHEET per calcolare quante pagine in un singolo pdf
# Così da darli direttamente in pasto a pdfjam

tmp_n=1 #Number of the starting page

# For first $EXTRA_SHEETS decks
for ((i = 0; i < $DECKS_NUM; i++)); do
    # echo "$tmp_n-$(( tmp_n + PAGES_PER_SHEET))"
    if [[ $i == $(( DECKS_NUM - 1 )) ]]; then
        pdfjam "$PDF_FILE" "$tmp_n-$TOTAL_PAGES_NUM" -o "o$tmp_n-$TOTAL_PAGES_NUM.pdf"
    else
        pdfjam --quiet "$PDF_FILE" "$tmp_n-$(( tmp_n + PAGES_PER_DECK - 1 ))" -o "o$tmp_n-$(( tmp_n + PAGES_PER_DECK - 1 )).pdf"
        tmp_n=$(( tmp_n + PAGES_PER_DECK)) # the first page of the next deck
    fi
done
# For remaining decks that will have less sheets
#for ((i=0; i<DECKS_NUM - EXTRA_SHEETS; i++)); do
    # echo "$tmp_n-$(( tmp_n + PAGES_PER_DECK_WITHOUT_EXTRA_SHEETS))"
    #pdfjam --quiet "$PDF_FILE" "$tmp_n-$(( tmp_n + PAGES_PER_DECK_WITHOUT_EXTRA_SHEETS ))" -o "o$tmp_n-$(( tmp_n + PAGES_PER_DECK_WITHOUT_EXTRA_SHEETS )).pdf"
    #tmp_n=$(( tmp_n + PAGES_PER_DECK_WITHOUT_EXTRA_SHEETS)) # the first page of the next deck
#done