# wget -qO MDgui.sh 'raw.githubusercontent.com/MachoDrone/Multi-Status-for-Nosana-Nodes/main/multistat.sh' && sudo bash MDgui.sh
## wget -qO - 'raw.githubusercontent.com/MachoDrone/Multi-Status-for-Nosana-Nodes/main/multistat-install.sh' | sudo -E bash
rm -r multistat.sh
wget https://raw.githubusercontent.com/MachoDrone/Multi-Status-for-Nosana-Nodes/main/multistat.sh
sudo chmod +x multistat.sh
echo "******************************************************"
echo "Now edit password and ip addresses in the script with: nano multistat.sh"
echo "Then run the scipt at any time with: ./multistat.sh"
echo "******************************************************"
# Prompt to edit the script for ip addresses and to change the password from yourpassword
read -p "Are you ready to edit? (y/n): " answer
if [[ "$answer" == "y" ]]; then
    nano multistat.sh
fi
