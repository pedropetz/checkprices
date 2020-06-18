#!/bin/bash

PROJDIR="/root/proj/checkPrice"
ITEMSFILE=$PROJDIR"/items.txt"
ERRDIR=$PROJDIR"/ERR"
PRICEDIR=$PROJDIR"/PRICE"

STORELIST="50,95,174,2329,3641,4339,6515,7037,8169,8477,8580,8802,8823,9129,9163,9163,9270,10526,10577,10897"

cd "$PROJDIR"

while IFS= read -r line
do
    ID=`echo $line | cut -d "," -f1`
    NAME=`echo $line | cut -d "," -f2`
    URL=`echo $line | cut -d "," -f3`

    wget $URL --output-document="$ID".in > $ERRDIR"/$ID".err 2>&1

    python3 checkPrice.py "$ID".in "$ID".out

    rm "$ID".in

    cat "$ID".out | grep "store-line store-line-active store-line-s" > "$ID".temp

    rm "$ID".out

    BSTORE=""
    BPRICE="99999.9"

    while IFS= read -r line2
    do
	STORE=`echo $line2 | cut -d "\"" -f2 | cut -d " " -f3 | sed -e "s/^store-line-s-//"`
	PRICE=`echo $line2 | cut -d "\"" -f6 | cut -d " " -f3 | sed -e "s/^store-line-s-//"`
	PRICE2=`echo $line2 | cut -d "\"" -f8 | cut -d " " -f3 | sed -e "s/^store-line-s-//"`

	#echo "$STORE" "$PRICE" "$PRICE2"

	if (( $(echo  "$BPRICE > $PRICE" | bc -l) ))
	then
	    if [[ $STORELIST == *$STORE* ]]
	    then
		BPRICE=$PRICE;
		BSTORE=$STORE;
	    fi
	fi

    done < "$ID".temp

    rm "$ID".temp


    NEW=`echo \`date '+%Y%m%d'\` "$BSTORE $BPRICE"`
    OLDP=`cat $PRICEDIR"/$ID".price | tail -n 1 | cut -d " " -f3`

    if [ "$BPRICE" != "$OLDP" ]
    then
	echo $NEW >> $PRICEDIR"/$ID".price
    fi


done < "$ITEMSFILE"




############################ falta comparar o id da loja com a lista de ids de lojas
############################ adicionar excepção da Mbit
############################ Validar ultimo registo de preço se não é igual
