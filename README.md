Skype in Ubuntu 18.04 container
================================
1. Download or clone two files - Dockerfile & skype-wrapper.pl
2. clone this folder to your ubuntu machine
3. go to the folder and run command : $ docker image build -t skypelinux .
4. On completion open command terminal and run : perl skyper-wrapper.pl
5. 'docker container ls' - can see container by name 'kas_myskype' is running.
6. Attach to the contianer : "$docker attach kas_myskype"
7. Once inside the container run "#skypeforlinux"
8. Your skype will start.
9. It will be there in the system tray and can be minimized.

Note: Make sure your network connection is up during the entire process.
