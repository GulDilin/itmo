#!/bin/bash -x

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
echo "DIAGRAMS_PATH=$SCRIPTPATH/diagrams"
cd "$SCRIPTPATH/diagrams"

# Export each drawio file
for file in $(ls *.drawio); do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  echo "Process file: $file"
  echo "Extract filename: $filename"

  # Export diagram to plain XML
  fullxml=$filename.xml
  echo "Export file: $fullxml"
  draw.io.exe --export --output "$fullxml" --format xml --uncompressed "$file"
  # Count how many pages based on <diagram element
  count=$(grep -o "<diagram" "$fullxml" | wc -l)

  # Export each page as an PNG
  # Page index is zero based
  for ((i = 0 ; i <= $count-1; i++)); do
    imgfile="$filename-$i.png"
    echo "Export file: $imgfile"
    # Exe file from windows used. Should be in path
    draw.io.exe --export --page-index $i --output "./img/$imgfile" "$file"
  done

  rm "$fullxml"
done

# Export mermaid diagrams
for file in $(ls *.mmd); do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  echo "Process file: $file"
  echo "Extract filename: $filename"

  imgfile="$filename.png"
  echo "Export file: $imgfile"

  mmdc -i "$file" -o "./img/$imgfile"
done
