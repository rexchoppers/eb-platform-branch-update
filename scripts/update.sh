#!/bin/bash

main_page() {
  choice=$(dialog --clear --stdout \
    --title "EB Platform Branch Update" \
    --menu "Choose:" 15 50 5 \
    1 "Do Something" \
    2 "Next Page" \
    3 "Exit")

  case $choice in
    1) echo "Did something" ;;
    2) page2 ;;   # defined in another file
    3) clear; exit ;;
  esac
}
