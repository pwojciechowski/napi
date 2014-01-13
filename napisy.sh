#!/bin/bash

echo "Start!"
date

convert_dir=~/tr/convert/
directory=~/tr/complete

cd $directory

find . -type d -mindepth 1 -maxdepth 1 | while read -r line; do

	find "$line" -iname "*.mkv" -exec mv '{}' $directory \;
	rm -rf "$line"

done

# czyszczenie sampli
find $directory -size -50M -name "*.mkv" -exec rm -f {}  \;

find $directory -iname "*.mkv" -exec /Users/pwojciechowski/scripts/napi/napi.sh -s '{}' \;

# czyszczenie błędnych pobrań
find $directory -size -100c -name "*.txt" -exec rm -f {} \;


find $directory -iname "*.txt" -exec /usr/local/bin/enca -x utf8 '{}' \;
find $directory | grep .txt | while read -r line; do
	filename=$(basename "$line")
	filename="${filename%.*}"
	if [ ! -f $directory"/"$filename".srt" ]; then
	  lineres=$(sed -n '2p' $line)

	  if [[ $lineres =~ ^[0-9][0-9]:[0-5][0-9]:[0-5][0-9],[0-9][0-9] ]]; then
    	cp $line $directory"/"$filename".srt"
	  else
    	/Users/pwojciechowski/scripts/napi/subotage.sh -i $line -o $directory"/"$filename".srt"
	  fi

	fi
done
find $directory | grep .mkv | while read -r line; do
	filename=$(basename "$line")
	filename="${filename%.*}"

	if [ -f $directory"/"$filename".txt" ]; then

		if [ -f $directory"/"$filename".srt" ]; then

			mv $line $convert_dir
			mv $directory"/"$filename".txt" $convert_dir
			mv $directory"/"$filename".srt" $convert_dir
		fi
	fi
done