#!/usr/bin/perl
use warnings;
use strict;
$\="\n";
$|++;


my $IMAGE = 'skypelinux';

my ($ENV_VARS,$VOLUMES);
print "skype wrapper PID : $$";

$ENV{'PATH'} = '/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/sbin:/usr/local/bin';
my $IMAGE_NAME = 'kas_myskype';

my $SKYPE_USER='skype';
chomp(my $USER_UID=`id -u`);
my $USER_GID=`id -g`;
my $XSOCK='/tmp/.X11-unix';
my $XAUTH='/tmp/.docker.xauth';
chomp(my $XDG_RUNTIME_DIR = `echo \$XDG_RUNTIME_DIR`);
my $PULSE_SERVER = $XDG_RUNTIME_DIR . '/pulse/native';
chomp(my $GROUP_AUDIO = `getent group audio | cut -d: -f3`);

# do we need to use sudo to start docker containers?
my $SUDO = system("id -Gn | grep -q docker") ? "sudo" : " ";
#print $SUDO;

my $DOWNLOAD_DIR = $ENV{'HOME'} . "/Downloads/skype_dir";
unless (-e $DOWNLOAD_DIR or mkdir $DOWNLOAD_DIR){
    print "$DOWNLOAD_DIR Directory exist";
 }

#print $DOWNLOAD_DIR;

sub docker_env_variables(){
  chomp($ENV_VARS.="--env USER_UID=$USER_UID");
  chomp($ENV_VARS.=" --env USER_GID=$USER_GID");
  chomp($ENV_VARS.=" --env DISPLAY=\$DISPLAY");
  chomp($ENV_VARS.=" --env XAUTHORITY=$XAUTH");
  chomp($ENV_VARS.=" --env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR");
  chomp($ENV_VARS.=" --env PULSE_SERVER=unix:$PULSE_SERVER");
  #$ENV_VARS.=" --env TZ=$(date +%Z)";
}

sub docker_volume_tobe_mounted() {
  `touch $XAUTH`;
  `xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -`;

  chomp($VOLUMES.="--volume $ENV{HOME}/.Skype:/home/$SKYPE_USER/.Skype");
  chomp($VOLUMES.=" --volume $DOWNLOAD_DIR:/home/$SKYPE_USER/Downloads");
  chomp($VOLUMES.=" --volume $XSOCK:$XSOCK:ro");
  chomp($VOLUMES.=" --volume $XAUTH:$XAUTH");
  chomp($VOLUMES.=" --volume $PULSE_SERVER:$PULSE_SERVER");
  chomp($VOLUMES.=" --volume ~/.config/pulse/cookie:/root/.config/pulse/cookie");
  #chomp($VOLUMES.=" --volume /run/user/$USER_UID/pulse:/run/user/$USER_UID/pulse");
}

sub docker_stopped_skype_instances_cleanup(){
  print("Cleaning up stopped skype instances...");
  my $c;
  foreach $c (`$SUDO docker ps -a -q`)
  {
     my $image= `$SUDO docker inspect -f {{.Name}} $c`;
     chomp($image);
     my $IM = "/" . $IMAGE_NAME;
     chomp($IM);
     if($image eq $IM){
        my $state = `$SUDO docker inspect -f {{.State.Running}} $c`;
        chomp($state);
        print $image . ' is running : ' . $state;
        if ($state eq "true")
        {
            print "Stopping Container : " . $IMAGE_NAME;
            `$SUDO docker stop $c > /dev/null`;
        }
        print "Removing Container : " . $IMAGE_NAME;
        `$SUDO docker rm $c > /dev/null`;
     }
  }
}


&docker_env_variables();
&docker_volume_tobe_mounted();
&docker_stopped_skype_instances_cleanup();
# print $ENV_VARS;
# print $VOLUMES;

my $cmd = "$SUDO docker run -it -d --device /dev/snd $ENV_VARS $VOLUMES --group-add $GROUP_AUDIO --name $IMAGE_NAME $IMAGE";

#my $cmd = "$SUDO docker run -it -d --device /dev/snd -e PULSE_SERVER=unix:/run/user/1000/pulse/native -v /run/user/1000/pulse/native:/run/user/1000/pulse/native -v ~/.config/pulse/cookie:/root/.config/pulse/cookie --group-add 29 --name $IMAGE_NAME $IMAGE /bin/bash";


print "RUN cmd: " . $cmd;
`$cmd`;



# foreach (sort keys %ENV) {
#   print "$_  =  $ENV{$_}";
# }
