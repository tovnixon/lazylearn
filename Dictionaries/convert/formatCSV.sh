#!/bin/bash
INPUT_FILE="de-en-enwiktionary.txt"
OUTPUT_FILE="de-en-dict_result.csv"
VERBOSE=false
while [ $# -gt 0 ] 
do
    case $1 in
        -i|--input) INPUT_FILE=$2;;
        -o|--output) OUTPUT_FILE=$2; shift ;;
        --) shift ; break;; 
        -*) 
            echo >&2 \
            "usage: . formatCSV.sh [-i input_file_name] [-o output_file_name]"
            exit 1;;
        *) break;;
    esac
    shift
done

if [ ! -e $INPUT_FILE ]; then
  echo "File $INPUT_FILE doesnt exists"
  exit 1
fi

echo "Start processing $INPUT_FILE"
echo ""

counter=0
while IFS= read -r s
do
    if [[ ${s:0:1} == "#"  ]]; then 
        continue
    fi

    firstSeparator=" {"
    partOfSpeech=$(echo $s | cut -d "{" -f2 | cut -d "}" -f1)
    meaning=$(echo $s | cut -d "(" -f2 | cut -d ")" -f1)

    # check if meaning is absend    
    trans_sep="::"
    if [[ "$meaning" == *"$trans_sep"* ]]; then
        meaning=""
    fi
    
    word=$(echo ${s%% {*})
    translation=$(echo ${s#*::})
    #remove unused data in translation
    # ' /' -> [
    translation=$(echo $translation | sed 's/ \//[/g')
    # / -> ]
    translation=$(echo $translation | sed 's/\//]/g')
    #  {} -> []
    translation=$(echo $translation | sed 's/{/[/g')
    translation=$(echo $translation | sed 's/}/]/g')
    # () -> []
    translation=$(echo $translation | sed 's/(/[/g')
    translation=$(echo $translation | sed 's/)/]/g')

        
    # remove space between words and commmas for [
    translation=$(echo $translation | sed 's/[  ]*\[/\[/g')
    # remove all inside []
    translation=$(echo $translation | sed 's/\[[^]]*\]//g')
    # trim spaces in the end
    translation=$(echo ${translation%%*( )})

    if [ "$VERBOSE" = true ] ; then
        echo "$s"
        echo "$word"
        echo "$partOfSpeech"
        echo "$meaning"
        echo "$translation"
    fi
    
    counter=$((counter+1))
    echo -n "."
    sep="|"
    echo "$word$sep$translation$sep$meaning$sep$partOfSpeech" >> $OUTPUT_FILE
    
done < "$INPUT_FILE"

echo ""
echo "Completed with $counter lines processed"