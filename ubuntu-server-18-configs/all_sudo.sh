#!/bin/bash
echo "Remember to set root password and to add everyone to admin group"
for ID in $(getent passwd | grep /home | cut -d ':' -f1); 
   do echo $ID; 
   adduser $ID admin; 
done

echo "SET ROOT PASSWORD TO root"
echo -e "root\nroot" | sudo passwd root

