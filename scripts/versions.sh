#!/bin/bash

show_versions() {
  versions=$(
    echo "=== AWS CLI Version ==="
    aws --version 2>&1
    echo
    echo "=== EB CLI Version ==="
    eb --version 2>&1
  )

  dialog --title "CLI Versions" \
         --msgbox "$versions" 15 60
}
