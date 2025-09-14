#!/bin/bash

home() {
  choice=$(dialog --clear --stdout \
    --title "Page 1: Elastic Beanstalk" \
    --menu "Choose an action:" 15 50 5 \
    1 "Update Platform Branch" \
    2 "Go to Config Page" \
    3 "Exit")

  case $choice in
    1) eb platform use --latest ;;
    2) page2 ;;   # jump to next page
    3) clear; exit ;;
  esac
}
