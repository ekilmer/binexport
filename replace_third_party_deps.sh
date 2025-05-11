#!/bin/bash

# Script to replace #include "third_party/absl/..." with #include <absl/...>

# Check if a directory argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory_to_search>"
  echo "Example: $0 ./src"
  exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory '$TARGET_DIR' not found."
  exit 1
fi

echo "Searching for files in '$TARGET_DIR'..."

# Find C/C++ source and header files and apply the sed command
# Common extensions: .h, .hpp, .hxx, .c, .cc, .cpp, .cxx
find "$TARGET_DIR" -type f \( \
  -name "*.h" -o \
  -name "*.hpp" -o \
  -name "*.hxx" -o \
  -name "*.c" -o \
  -name "*.cc" -o \
  -name "*.cc.in" -o \
  -name "*.cpp" -o \
  -name "*.cxx" \
  \) -print0 | while IFS= read -r -d $'\0' file; do
  # Use sed to perform the replacement in-place
  # s|^#include "third_party/absl/\(.*\)"|#include <absl/\1>|
  # ^                                      - Start of the line
  # #include "third_party/absl/           - Matches the literal string
  # \(.*\)                                 - Captures the rest of the path (e.g., "strings/string_view.h") into group 1
  # "                                      - Matches the closing quote
  # #include <absl/\1>                     - Replacement string: uses <absl/ followed by the captured group 1 and >
  # The -i flag modifies the file in-place.
  sed -i 's|^#include "third_party/absl/\(.*\)"|#include <absl/\1>|' "$file"
  if grep -q '#include <absl/' "$file"; then
    echo "Processed: $file"
  fi
done

echo "Replacement process complete."
echo "Please review the changes, especially if you are not using version control."
