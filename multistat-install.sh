#!/bin/sh
# wget -qO MDgui.sh 'raw.githubusercontent.com/MachoDrone/Multi-Status-for-Nosana-Nodes/main/multistat.sh' && sudo bash MDgui.sh
## wget -qO - 'raw.githubusercontent.com/MachoDrone/Multi-Status-for-Nosana-Nodes/main/multistat.sh' | sudo -E bash
wget https://raw.githubusercontent.com/MachoDrone/Multi-Status-for-Nosana-Nodes/main/multistat.sh
chmod +x multistat.sh
echo "************************************************"
echo "Now edit password and ip addresses in the script"
echo "************************************************"
sleep 12
nano multistat.sh
