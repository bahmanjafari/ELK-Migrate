#!/bin/bash


echo "driection: dump"
OUTPUT=$(ps -ef | grep "multielasticdump --direction=dump" | wc -l)
NEWLINE=$'\n'

if [ ${OUTPUT} == 2 ]
then
echo multielasticdump dump already run
else
        # Note: Numbers are 1024-byte units on Linux,
        #       and 512-byte units on macOS.
        reqSpace=100000000
        availSpace=$(df "$HOME" | awk 'NR==2 { print $4 }')
        if (( availSpace < reqSpace )); then
          echo "not enough Space" >&2
          exit 1
        fi


        echo multielasticdump dump no run
        SOURCE=$(curl -X GET -s "http://[username]:[PASSWORD]@[IP_ADDRESS]:9200/_cat/indices/:[indices_name]*?v=true&s=index&pretty" | awk '{ print $3 }')
        T=$(curl -X GET -s "http://[username]:[PASSWORD]@[IP_ADDRESS]:9200/_cat/indices/:[indices_name]*?v=true&s=index&pretty" | wc -l )
        DESTINITION=$(curl -X GET -s "http://[username]:[PASSWORD]@192.168.2.108:9200/_cat/indices/:[indices_name]*?v=true&s=index&pretty" | awk '{ print $3 }')
        Y=$(curl -X GET -s "http://[username]:[PASSWORD]@192.168.2.108:9200/_cat/indices/:[indices_name]*?v=true&s=index&pretty" | wc -l )
        DESTINTION2=$( ls -1 /tmp/elk |grep :[indices_name] | cut -c1-31)
        R=$(ls -1 /tmp/elk | cut -c1-31 | wc -l )

        for (( c=2 ; c<=$T ; c++))
        do
                A=`echo $SOURCE | awk '{print $'$c'}'`
                B+=$NEWLINE$A
        done
        for (( i=3 ; i<=$Y ; i++ ))
        do
                D=`echo $DESTINITION | awk '{print $'$i'}'`
                F+=$NEWLINE$D
        done


        for (( j=5; j<=$R; j=((j+4))))
        do
                M=`echo Local $DESTINTION2 |grep :[indices_name] | awk '{print $'$j'}'`
                N+=$NEWLINE$M
        done

        H=$F$N
        Q=`echo "$H" | wc -l`

#       echo source is: $B
#       echo destinition is: $H

        final=`comm -23 <(tr ' ' $'\n' <<< $B | sort) <(tr ' ' $'\n' <<< $H | sort)`
        count=`echo "$final" | wc -l`
        for (( l=1 ; l<=$count ; l++ ))
        do
                D=`echo $final | awk '{print $'$l'}'`
                echo $D
                multielasticdump \
                --direction=dump \
                --match='.'*$D'.*' \
                --limit=5000 \
                --concurrency=5 \
                --ignoreChildError=true \
                --input=http://[username]:[PASSWORD]@[IP_ADDRESS]:9200 \
                --output=/tmp/elk
               break
        done
fi
      
