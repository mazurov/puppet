#!/bin/sh
sudo puppet --templatedir=~/UbuntuOne/System/Puppet/files ~/UbuntuOne/System/Puppet/manifests/desktop.pp
echo -n "Press any key to exit..."
read foo
