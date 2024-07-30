**Monitor a glimpse of every headless Nosana Node on your network**
The script logs-into each of your PCs you add to the script and checks the Node's live Docker log. 
- Copy all the following for the **Installer:**
  - `wget -qO multistat-install.sh 'raw.githubusercontent.com/MachoDrone/Multi-Status-for-Nosana-Nodes/main/multistat-install.sh' && sudo bash multistat-install.sh`

- run with `./multistat.sh`

* **Assumptions**
  - you have the same username and password on every headless Node
  - edit the script and replace ***yourpassword*** with your real password
  - edit the script and **add/remove** the necessary ip addresses in the script for your environment

 Every time the script runs it's capturing a snapshot of a live log from your Node's Docker.. the length of text will vary for each node status.
.
option to download without installer:
`wget https://raw.githubusercontent.com/MachoDrone/Multi-Status-for-Nosana-Nodes/main/multistat.sh`
  
![alt text](https://github.com/MachoDrone/Multi-Status-for-Nosana-Nodes/blob/ea3e1c8fff1062bb8d2b5700280bcad047a8779f/multistat-screen-shot.png)
