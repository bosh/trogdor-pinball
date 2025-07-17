#!/bin/sh
echo -ne '\033c\033]0;Videlectrix\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Videlectrix.x86_64" "$@"
