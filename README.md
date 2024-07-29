**Monitor a glimpse of every headless Nosana Node on your network**
  
- **Installer:** - `wget -qO multistat-install.sh 'raw.githubusercontent.com/MachoDrone/Multi-Status-for-Nosana-Nodes/main/multistat-install.sh' && sudo bash multistat-install.sh`
  
* **Assumptions**
  - you have the same username and password on every headless Node
  - edit the script and replace ***yourpassword*** with your real password
  - edit the script and **add/remove** the necessary ip addresses in the script for your environment

  - run with `./multistat.sh`

  Every time the script runs it's capturing a snapshot of a live log from your Node's Docker.. the length of text will vary for each node status.
