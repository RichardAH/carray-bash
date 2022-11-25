#!/bin/bash
if [ -z "$@" ]
then
    while read -r l
    do
        line="$line$l"
    done
fi

C="`echo \"$@$line\" | tr -d '\n' | tr -d ' ' | tr -d '\t' | tr '[:lower:]' '[:upper:]' | tr 'X' 'x'`"

if [ "`echo \"$C\" | grep -Eo '[^A-F0-9xU,{}]' | wc -l`" -gt "0" ]
then
    echo "Garbage in input, expecting hex!"
    exit 1
fi

# check to see if the array is already comma broken
if [ "`echo \"$C\" | grep -Eo '(,|x)' | wc -l`" -eq "0" ]
then

    C="`echo \"$C\" | tr -d '{' | tr -d '}' | tr -d '\n'`"

    # add a leading zero if needed
    ODD="`echo \"$C\" | tr -d '\n' | wc -c`"
    if [ "`expr $ODD % 2`" -eq "1" ]
    then
        C="0$C"
    fi

    # split by comma
    C="`echo \"$C\" | 
        sed -E 's/[A-Fa-f0-9]{2}/0x\0U,/g' | 
        sed -E 's/,$//g'`"
fi

# add curly braces if they're missing
if [ "`echo \"$C\" | grep -Eo '[\{\}]' | wc -l`" -eq "0" ]
then
    C="{$C}"
fi

echo "$C" | 
    sed -E 's/\{/\0\n/g' | 
    sed -E 's/((0x[0-9A-Fa-f]{1,2}U,){9}(0x[0-9A-Fa-f]{1,2}U[,]?))/    \0\n/g' |
    sed -E 's/.*}$/    \0/g' |
    sed -E 's/\}(;)?/\n}\1\n/g' |
    tr '\n' '~' |
    sed -E 's/~ +~/~/g' |
    sed -E 's/,~\}/~}/g' |
    sed -E 's/\};?/};/g' |
    tr '~' '\n'
