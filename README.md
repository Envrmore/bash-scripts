# Welcome to bash-scripts #
This repository is dedicated to share bash scripts for Linux (preferably Debian 11/Bullseye) utilities. Most of the scripts that are uploaded here are either originally-made,
taken from online sources with some edits or tweaks, or completely copy-pasted from the internet. More scripts will be added so just be patient.

### How to get bash scripts? ###
***
#### 1. Using git-clone ####
> [!WARNING]
> Some distributions don't include git automatically. Make sure to check the availability of git first.<br>

Go to your Linux terminal, and put this command : `git clone https://github.com/Envrmore/bash-scripts`. This will clone (download) the entire content of this repository.
To target specific file from this repository, you can use this command: `git clone https://github.com/Envrmore/bash-scripts`.

#### 2. Using FTP or SFTP ####
This method is potentially better when there is limited-to-no internet connectivity.<br>
-On Debian-based distributions, install a FTP server (ProFTPD) : `sudo apt update` then `sudo apt install proftpd -y`. Then, just connect to your Linux from other devices 
that have the scripts to transfer the file using FTP client (on Windows : WinSCP, FileZilla).
<br>
<br>
<br>
### How to use (invoke) bash scripts? ###
***
You need to give execute permission for the script by using the following command: `sudo chmod +x something.sh`.<br>
After that on your machine you can use the `bash` command for calling the script, or by directly specifying the path to the script.
Scenario example: You have the script on your machine already, it is located on /home/username. To execute the script you can go to the directory of
the script first: `cd /home/username` then run `./something.sh`. Or, you can just directly call the script with its path: `/home/username/something.sh`.