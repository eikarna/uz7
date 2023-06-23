#!/bin/bash

# Check User Input
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 target_folder output_file[.7z]"
  exit 1
fi

# Check if zpaq is installed
if ! command -v zpaq &> /dev/null; then
  echo "zpaq command not found. Please make sure zpaq is installed and added to the system's binary directories."
  exit 1
fi

# Check if 7z is installed
if ! command -v 7z &> /dev/null; then
  echo "tar command not found. Please make sure tar is installed and added to the system's binary directories."
  exit 1
fi

# Some Variables
TEMPDIR=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1`
INT=0

# Compression Logic
while IFS= read -r -d '' file; do
  INT=$(( INT + 1 ))
  echo "Processing $file file..."
  # Determine the relative path of the file
  rel_path="${file%/*}"

  bn=`basename "$rel_path"`

  parp=`basename "$1"`
  chip=`basename "$(dirname "$file")"`

  if [ "$parp" != "$chip" ]; then
      output_dir="$TEMPDIR/$bn"
      # echo "OutputDir: $output_dir"
      mkdir -p "$output_dir"
  else
      output_dir="$TEMPDIR"
  fi
  # Take action on each file. $file stores the current file name
  zpaq a "$output_dir/$INT.zpaq" "$file" -f -m5 -t8 &> /dev/null
done < <(find "$1" -type f -print0)

7z a -mmt4 -mx9 "$2" "$TEMPDIR"

#Remove TempDir
rm -rf "$TEMPDIR"
