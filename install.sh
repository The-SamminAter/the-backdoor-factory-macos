#!/bin/bash
#used to be this: #!/usr/bin/env bash

#A fixed backdoor-factory installer"
#Thank you stackexchange
#Especially for the python fix
#That was one of the biggest problems
#(https://stackoverflow.com/questions/44316292/ssl-sslerror-tlsv1-alert-protocol-version)

if [[ $EUID -ne 0 ]]; then
	echo "Starting"
#Originally this script required root/sudo. 
#Because Homebrew doesn't support that anymore, 
#it has to be run as a regular user, and includes a lot of sudo -H usage
else 
	echo "This can't be run as root/sudo, because of Homebrew"
	echo "Please run as a normal user"
	exit 1
fi

#OS X appack install
uname -a | grep -i Darwin &> /dev/null
if [ $? -eq 0 ]; then
#donesetup check
if [ ! -f donesetup ]; then
#pre donesetup
echo ""
echo "A couple of things have to be installed to run/build this"
echo "Checking if the required tools are installed"
echo
#Xcode command-line tools check
echo "Checking for Xcode command-line tools. If not present, they will be installed"
xcode-select --install
fi
#Homebrew check
echo "Checking for Homebrew"
if [ -f /usr/local/bin/brew ]; then
	echo "Homebrew is already installed"
else
	read -p "Homebrew is not installed. Would you like to install Homebrew? [Y/n]" answer;
	#do
	case $answer in
		[yY]* )
		echo "Attmepting to install Homebrew"
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		;; 
		[nN]* )
		echo "Homebrew needs to be installed"
		python -mwebbrowser https://brew.sh
		exit 1
	esac
fi
#Anaconda check
echo "Checking for Anaconda, as it needs to not be"
if [ -f /Applications/Anaconda ]; then
	echo "Anaconda is installed"
	read -p "Would you like to remove Anaconda? [Y/n]" answer;
	#do
	case $answer in
		[yY]* )
		echo "Attmepting to remove Anaconda"
		echo
		echo "Installing Anaconda-clean"
		conda install anaconda-clean
		echo "Uninstalling Anaconda"
		anaconda-clean --yes
		echo "Anaconda-clean has finished running, deleting leftover files (including Anaconda backup)"
		echo "This will require your password"
		sudo rm -rf ~/anaconda3 ~/.anaconda_backup ~/.spyder-py3 /anaconda3
		echo "Anaconda has been removed"
		;;
		[nN]* )
		echo "Anaconda needs to be removed, as it'll screw with pip/python"
		exit 1
	esac
else
	echo "Anaconda isn't installed"
fi
#Brew-installable tools check
echo
echo "Checking for required brew-installable tools"

if [ -f /usr/local/bin/autoconf ]; then
   echo "autoconf is already installed"
else
   echo "autoconf is not installed. Attmepting to install"
   brew install autoconf
fi

if [ -f /usr/local/bin/automake ]; then
   echo "automake is already installed"
else
   echo "automake is not installed. Attmepting to install"
   brew install automake
fi
#I only know capstones's brew dir
if [ -f /usr/local/Cellar/capstone/4.0.1/bin/cstool ]; then
	echo "(brew) capstone is already installed"
else
	echo "capstone does not appear to have been installed (using Homebrew)"
	echo "Has it been installed from elsewhere? [Y/n]"
	read -p "If it has, Homebrew won't install capstone" answer;
	#do
	case $answer in
		[yY]* )
		echo "capstone has been installed from elsewhere"
		echo "Moving on"
		;;	
		[nN]* )
		echo "Attmepting to install capstone"
		brew install capstone
	esac
fi

#I only know libgsf's brew dir
if [ -f /usr/local/Cellar/libgsf/1.14.46_1/bin/gsf ]; then
	echo "(brew) libgsf is already installed"
else
	echo "libgsf does not appear to have been installed (using Homebrew)"
	echo "Has it been installed from elsewhere? [Y/n]"
	read -p "If it has, Homebrew won't install libgsf" answer;
	#do
	case $answer in
		[yY]* )
		echo "libgsf has been installed from elsewhere"
		echo "Moving on"
		;;	
		[nN]* )
		echo "Attmepting to install libgsf"
		brew install libgsf
	esac
fi

if [ -f /usr/local/bin/glibtoolize ]; then
	echo "libtool is already installed"
else
	echo "libtool is not installed. Attmepting to install"
	brew install libtool
fi

#libtoolize link check
if [ -f /usr/local/bin/libtoolize ]; then
	printf ""
else
	echo "Your password is required to create a glibtoolize link in /usr/local/bin/"
	sudo ln -s /usr/local/bin/glibtoolize /usr/local/bin/libtoolize
fi

if [ -f /usr/local/bin/osslsigncode ]; then
	echo "osslsigncode is already installed"
else
	echo "osslsigncode is not installed. Attmepting to install"
	brew install osslsigncode
fi
#Python/pip fix 
echo
echo "Installing Python/pip fix"
echo "This will require your password"
#Test if fix works
sudo -H pip install python-fix/asn1crypto-0.24.0-py2.py3-none-any.whl
sudo -H pip install python-fix/enum34-1.1.6-py2-none-any.whl
sudo -H pip install python-fix/ipaddress-1.0.22-py2.py3-none-any.whl
sudo -H pip install python-fix/pyOpenSSL-19.0.0-py2.py3-none-any.whl
sudo -H pip install python-fix/six-1.12.0-py2.py3-none-any.whl
echo "Python/pip fix installed"
#Update pip
echo
echo "Updating pip"
pip install --update pip
#Python requirement instalation
echo
echo "Installing Python packages"
read -p "Would you like to install these from online [1] or from local packages [2]?" answer;
#do
case $answer in
	"1")
	echo "Installing required packages from online"
	echo "This will require your password"
	sudo -H pip install requests
	sudo -H pip install requests[security]
	sudo -H pip install pefile
	sudo -H pip install capstone
	;;
	"2")
	echo "Installing local required packages"
	echo "This will require your password"
	echo
	#requests and requests[security]
	echo "Installing packages for requests"
	sudo -H pip install python-packages/requests/certifi-2019.9.11-py2.py3-none-any.whl
	sudo -H pip install python-packages/requests/chardet-3.0.4-py2.py3-none-any.whl
	sudo -H pip install python-packages/requests/idna-2.8-py2.py3-none-any.whl
	sudo -H pip install python-packages/requests/requests-2.22.0-py2.py3-none-any.whl
	sudo -H pip install python-packages/requests/urllib3-1.25.4-py2.py3-none-any.whl
	#requests[security]
	echo
	echo "requests[security] packages can not be installed offline"
	read -p "Would you like to install requests[security] from online? [Y/n]" answer;
	#do
	case $answer in
		[yY]* )
		echo "Installing requests[security]"
		echo "You may be asked for your password"
		sudo -H pip install requests[security]
		;;
		[nN]* )
		echo "Ok, requests[security] won't be installed"
	esac
	#capstone
	echo
	echo "Installing package for capstone"
	sudo -H pip install python-packages/capstone/capstone-4.0.1.tar.gz
	#pefile
	echo
	echo "Installing packages for pefile"
	sudo -H pip install python-packages/pefile/future-0.17.1.tar.gz
	sudo -H pip install python-packages/pefile/pefile-2019.4.18.tar.gz	
#done packages
echo
echo "Done installing packages"
echo
esac
#create donesetup
touch donesetup 
#else for donesetup
else
	echo "donesetup found"
fi
#Start building
echo "Starting installation"
echo '[*] Install osslsigncode'
cd osslsigncode
./autogen.sh
./configure
make
make install
cd ..	
cd ./aPLib/example/
clang -c -I../lib/macho64 -Wall -O2  -o appack.o appack.c -v 
clang -Wall -O2  -o appack appack.o ../lib/macho64/aplib.a -v 
cp ./appack /usr/local/bin/appack
#first if else
else
	echo "This script can't be run"
fi
