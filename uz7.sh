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

# Check if tar is installed
if ! command -v tar &> /dev/null; then
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
  rel_path="${file#$1/}"

  # Create the output directory structure
  output_dir="$TEMPDIR/$(dirname "$rel_path")"
  mkdir -p "$output_dir"

  # Take action on each file. $file stores the current file name
  zpaq a "$output_dir/$INT.zpaq" "$file" &> /dev/null
done < <(find "$1" -type f -print0)

7z a -mmt4 -mx9 -m0=lzma2:a0 -ssw "$1" "$TEMPDIR"

#Remove TempDir
rm -rf "$TEMPDIR"
