**Monitor a glimpse of every headless Nosana Node on your network**
  
  
* **Assumptions**
  - installing **sshpass** is required `sudo apt install sshpass`
  - you are running linux and not WSL
  - you have the same username and password on every headless linux PC
  - you can edit the script and replace ***yourpassword*** with your real password
  - you can edit the script and add/remove the necessary ip addresses in the script for your environment

  - the name of the script is multistat.sh
  - make executable with `chmod +x multistat.sh`
  - run with `./multistat.sh`

  Every time the script runs it's capturing a snapshot of a live log from your Node's Docker.. the length of text will vary for each node status.
