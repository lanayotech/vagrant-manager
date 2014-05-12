# Vagrant Manager for OS X

Vagrant Manager is a OS X Status Bar icon that lets you manage all of your vagrant machines from one central location.
More information is available at http://vagrantmanager.com/

## Downloads
Download Vagrant Manager from the [GitHub Releases Page](https://github.com/lanayotech/vagrant-manager/releases)

## Installation Notes
* Vagrant Manager is currently only available for OS X
* Vagrant Manager is currently only compatible with the VirtualBox provider for Vagrant
* Make sure that you have VirtualBox and Vagrant installed, and the vboxmanage and vagrant commands are in your path so that Vagrant Manager can execute them
* Currently, vagrant machines must already be initialized in order for Vagrant Manager to detect them. Make sure you have run vagrant init on any machine you want to appear in Vagrant Manager. Once Vagrant Manager has detected a machine, you can bookmark it so that it will not disappear when you destroy the machine. You can also manually add a bookmark and specify the path to your Vagrantfile
* In order to launch Vagrant Manager at login, add it to your Login Items under System Preferences -> Users & Groups

