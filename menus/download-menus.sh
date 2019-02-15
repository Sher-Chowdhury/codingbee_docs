# you need to source this script while in this directory. 

list_of_menus=$(wp menu list --fields=name | tail -n +2)

echo $list_of_menus

for menu in $list_of_menus; do 
  wp menu item list --format=yaml $menu > $menu.yml
done
