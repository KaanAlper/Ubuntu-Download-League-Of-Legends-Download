1)Download Staging Wine 

2)sudo apt update

6)Install Lutrix

7)https://lutris.net/games/league-of-legends/ İnstall Standart Version

8)https://lol.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.na.exe download

9)After Setup, if wont happen anything, stop riot from task manager

11)Create Folder in Desktop or somewhere and drop "syscall_check.sh" and "launchhelper.sh" here

12)Open Cmd in that folder and write

sudo chmod +x syscall_check.sh

sudo chmod +x launchhelper.sh

13)Go to the Game Configure and System Options

14)Click Show Advenced Options

15)Add "launchhelper.sh" location to "Pre-launch script" in System Options

16)Keep "Wait for pre-launch script completion" and "Enable Feral Gamemode" Off in System Options

17) sudo sh -c 'sysctl -w abi.vsyscall32=0'

18) reboot

19) Launch the game...
