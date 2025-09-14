#!/bin/bash

choice=$(dialog --clear --stdout \
  --title "Elastic Beanstalk Helper" \
  --menu "Choose an action:" 15 50 5 \
  1 "Update Platform Branch" \
  2 "Show Config" \
  3 "Exit")

case $choice in
  1) eb platform use --latest ;;
  2) eb config ;;
  3) clear; exit ;;
esac
