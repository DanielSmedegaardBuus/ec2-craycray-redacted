#!/bin/bash

su -c "echo 'export EDITOR=nano' >> ~/.bashrc" ubuntu
su -c "echo '[[ -e /.env-pub ]] && . /.env-pub' >> ~/.bashrc" ubuntu
su -c "sed -Ei 's/^#force_color_prompt=yes/force_color_prompt=yes/' ~/.bashrc" ubuntu
su -c "echo 'alias lla=\"ll -a\"' >> ~/.bashrc" ubuntu
su -c "echo 'alias llh=\"ll -h\"' >> ~/.bashrc" ubuntu
su -c "echo 'alias delete-mail-queue=\"sudo postsuper -d ALL\"' >> ~/.bashrc" ubuntu
su -c "echo \"alias localip='echo \\\$EC2_LOCAL_IPV4'\" >> ~/.bashrc" ubuntu
su -c "echo \"alias publicip='echo \\\$EC2_PUBLIC_IPV4'\" >> ~/.bashrc" ubuntu
su -c "echo \"alias instance='echo \\\$INSTANCE_NAME'\" >> ~/.bashrc" ubuntu
su -c "echo \"PS1='\\\${debian_chroot:+(\\\$debian_chroot)}\[\033[01;34m\]\\\$INSTANCE_NAME \[\033[01;36m\]\\\$EC2_PUBLIC_IPV4 \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\\\\]\\\\\\\$ '\" >> ~/.bashrc" ubuntu
