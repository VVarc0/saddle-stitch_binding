#! /bin/bash

PDF_FILE=$1
TOTAL_PAGES_NUM=$(pdfinfo ${PDF_FILE} | grep "Pages:" | sed 's/Pages:[ \t]*//')

if [[ $(( (TOTAL_PAGES_NUM / 4) % 2 )) == 0 ]]; then
    echo "$(( (TOTAL_PAGES_NUM / 4) )) Pari"

fi

mkdir ./tmp

tmp_list=()

i=1
j=$TOTAL_PAGES_NUM
[[ $(( (TOTAL_PAGES_NUM / 4) % 2 )) != 0 ]] && pdfjam --quiet "$PDF_FILE" "${i},{}" -o "./tmp/tmp_${i},{}.pdf" && echo "tmp_$i,{}" && tmp_list+=("./tmp/tmp_${i},{}.pdf")
 

# Math trick btwb
for (( i = $(( $i + 1 )) , j ; i<=$(( (TOTAL_PAGES_NUM + 2 -1) / 2 )) && j>=(( TOTAL_PAGES_NUM / 2 )) ; i++, j-- )); do
    echo "tmp_$i,$j"
    pdfjam --quiet "$PDF_FILE" "$i,$j" -o "./tmp/tmp_${i},${j}.pdf"
    tmp_list+=("./tmp/tmp_${i},${j}.pdf")
done

    pdfjam --quiet "${tmp_list[@]}" -o "./prova_giunzione.pdf"


rm -r ./tmp