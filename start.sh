#!/bin/bash

# Set the path to watch for new files
WATCH_PATH="test"

# Determine which command to use based on the operating system
if [[ $(uname) == 'Linux' ]]; then
  WATCH_CMD="inotifywait -qme close_write --format '%w%f' ${WATCH_PATH}"
elif [[ $(uname) == 'Darwin' ]]; then
  WATCH_CMD="fswatch -r ${WATCH_PATH}"
fi

# Infinite loop to keep watching for new files
while true; do
  echo "Watching for new files in ${WATCH_PATH}..."
  
  # Use the appropriate command to watch for new files
  eval "${WATCH_CMD}" | while read file; do
    # Check if the file is a regular file
    if [[ -f "$file" ]]; then
      filename=$(basename -- "$file")
      dirname="${filename%.*}"
      
      # Check if a folder with the same name already exists
      if [[ -d "${WATCH_PATH}/${dirname}" ]]; then
        :
      else
        mkdir "${WATCH_PATH}/${dirname}"
        mv "$file" "${WATCH_PATH}/${dirname}"
        echo "Moved ${filename} to ${WATCH_PATH}/${dirname}"
      fi
    fi
  done
  
  # Wait 15 seconds before checking for new files again
  sleep 15
done
