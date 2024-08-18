#**Monitor a local PC or every headless Nosana Node on your network**
All you need are the IP addresses. 
- Copy all the following for the **Installer:**
  - `wget -qO multistat-install.sh 'raw.githubusercontent.com/MachoDrone/Multi-Status-for-Nosana-Nodes/main/multistat-install.sh' && sudo bash multistat-install.sh`

- run with `./multistat.sh`

* **Assumptions**
  - you have the same username and password on every headless Node
  - edit the script and replace ***yourpassword*** with your real password
  - edit the script and **add/remove** the necessary ip addresses in the script for your environment

.
option to download without installer:
`wget https://raw.githubusercontent.com/MachoDrone/Multi-Status-for-Nosana-Nodes/main/multistat.sh`
then `chomod +x multistat.sh`
start `./multistat.sh`
  
![alt text](https://github.com/MachoDrone/Multi-Status-for-Nosana-Nodes/blob/main/multistat-image.png?raw=true)
