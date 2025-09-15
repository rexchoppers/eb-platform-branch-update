#!/bin/bash

home() {
  choice=$(dialog --clear --stdout \
    --title "EB Platform Branch Update" \
    --menu "Choose an action:" 15 50 5 \
    1 "Update Platform Branch" \
    2 "Show Versions" \
    3 "Exit")

  case $choice in
    1) configure_aws ;;
    2) show_versions ;;
    3) clear; exit ;;
  esac
}
