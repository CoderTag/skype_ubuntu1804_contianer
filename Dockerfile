FROM ubuntu@sha256:f08638ec7ddc90065187e7eabdfac3c96e5ff0f6b2f1762cf31a4f49b53000a5

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y apt-utils wget gnupg
RUN echo "deb [arch=amd64] https://repo.skype.com/deb stable main" | tee /etc/apt/sources.list.d/skype-stable.list

RUN wget https://repo.skype.com/data/SKYPE-GPG-KEY && apt-key add SKYPE-GPG-KEY
RUN apt-get update
RUN apt-get install -y apt-transport-https skypeforlinux alsa-base alsa-utils pulseaudio

#CMD ['skypeforlinux']
#WORKDIR /home/skype/Downloads
#RUN wget "https://go.skype.com/skypeforlinux-64.deb"
#RUN apt install ./skypeforlinux-64.deb
