#!/usr/bin/env bash

# Function to display usage
usage() {
    echo "Usage: $0 <source_file> <destination_path>"
    echo "Copies <source_file> to <destination_path>."
    echo "<destination_path> can be a directory or a target filename."
    echo "If the final target file already exists,"
    echo "a numeric suffix (e.g., _1, _2) is appended to its name."
    exit 1
}

# --- Main Script ---

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    usage
fi

SOURCE_FILE="$1"
DEST_INPUT="$2" # The user's second argument

# 1. Validate source file
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file '$SOURCE_FILE' does not exist or is not a regular file."
    exit 1
fi

# 2. Determine the effective destination directory and target filename
#    This logic mimics how 'cp' behaves.

EFFECTIVE_DEST_DIR=""
EFFECTIVE_FILENAME=""

# Case 1: DEST_INPUT is an existing directory
if [ -d "$DEST_INPUT" ]; then
    EFFECTIVE_DEST_DIR="$DEST_INPUT"
    EFFECTIVE_FILENAME=$(basename "$SOURCE_FILE")
# Case 2: DEST_INPUT is intended to be a file (or a new file in a yet-to-be-checked dir)
else
    # Get the directory part of DEST_INPUT
    PROPOSED_DEST_DIR=$(dirname "$DEST_INPUT")
    # If dirname returns ".", it means the current directory.
    # We need to ensure it's a valid directory.
    if [ "$PROPOSED_DEST_DIR" == "." ]; then
        PROPOSED_DEST_DIR_CHECK="." # Current directory
    else
        PROPOSED_DEST_DIR_CHECK="$PROPOSED_DEST_DIR"
    fi

    if [ ! -d "$PROPOSED_DEST_DIR_CHECK" ]; then
        echo "Error: Destination directory '$PROPOSED_DEST_DIR' (for target '$DEST_INPUT') does not exist."
        echo "You might need to create it first (e.g., mkdir -p \"$PROPOSED_DEST_DIR\")"
        exit 1
    fi
    EFFECTIVE_DEST_DIR="$PROPOSED_DEST_DIR"
    EFFECTIVE_FILENAME=$(basename "$DEST_INPUT")
fi

# Normalize EFFECTIVE_DEST_DIR (remove trailing slash if any, except if it's just "/")
if [[ "$EFFECTIVE_DEST_DIR" != "/" && "$EFFECTIVE_DEST_DIR" == */ ]]; then
    EFFECTIVE_DEST_DIR="${EFFECTIVE_DEST_DIR%/}"
fi
# If dirname was '.', use the actual current path for constructing TARGET_PATH
if [ "$EFFECTIVE_DEST_DIR" == "." ]; then
   TARGET_PATH="./$EFFECTIVE_FILENAME" # ensure it's treated as a relative path
else
   TARGET_PATH="$EFFECTIVE_DEST_DIR/$EFFECTIVE_FILENAME"
fi


# Check if the target file already exists
if [ -e "$TARGET_PATH" ]; then
    echo "File '$TARGET_PATH' already exists. Finding a unique name..."

    # Use EFFECTIVE_FILENAME for splitting name and extension
    NAME_PART="${EFFECTIVE_FILENAME%.*}"
    EXT_PART="${EFFECTIVE_FILENAME##*.}"

    if [[ "$NAME_PART" == "$EFFECTIVE_FILENAME" ]] || [[ "$EXT_PART" == "$EFFECTIVE_FILENAME" && "$EFFECTIVE_FILENAME" == "$NAME_PART" ]]; then
        BASE_NAME="$EFFECTIVE_FILENAME"
        EXTENSION=""
    else
        BASE_NAME="$NAME_PART"
        EXTENSION=".$EXT_PART"
    fi

    COUNTER=1
    NEW_FILENAME_SUFFIXED="${BASE_NAME}_${COUNTER}${EXTENSION}"
    if [ "$EFFECTIVE_DEST_DIR" == "." ]; then
        NEW_TARGET_PATH="./$NEW_FILENAME_SUFFIXED"
    else
        NEW_TARGET_PATH="$EFFECTIVE_DEST_DIR/$NEW_FILENAME_SUFFIXED"
    fi


    while [ -e "$NEW_TARGET_PATH" ]; do
        COUNTER=$((COUNTER + 1))
        NEW_FILENAME_SUFFIXED="${BASE_NAME}_${COUNTER}${EXTENSION}"
        if [ "$EFFECTIVE_DEST_DIR" == "." ]; then
            NEW_TARGET_PATH="./$NEW_FILENAME_SUFFIXED"
        else
            NEW_TARGET_PATH="$EFFECTIVE_DEST_DIR/$NEW_FILENAME_SUFFIXED"
        fi
    done
    TARGET_PATH="$NEW_TARGET_PATH"
    echo "Using unique name: '$TARGET_PATH'"
fi

# Perform the copy operation
echo "Copying '$SOURCE_FILE' to '$TARGET_PATH'..."
if cp "$SOURCE_FILE" "$TARGET_PATH"; then
    echo "File copied successfully."
else
    echo "Error: Failed to copy file."
    exit 1
fi

exit 0