# you need to source this script while in this directory. 

list_of_menus=$(wp menu list --fields=name | tail -n +2)
