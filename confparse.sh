#!/usr/bin/env zsh
grep "^$2%" "$1" | cut -d '%' -f"$(( 1 + $3 ))"
