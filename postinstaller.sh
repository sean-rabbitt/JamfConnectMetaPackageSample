#!/bin/bash

# Jamf Connect Meta Package post installer example
# S. Rabbitt - 17 FEB 2021

# We are wrapping the JamfConnect.pkg in this package with additional branding
# images, scripts, help files, etc. for a zero touch enrollment.
#
# Lastly, after all is installed, we check to see what the current state of 
# the user experience is showing
# * If it's in the user space, we assume that the user is in Finder and working
#   on the computer - do nothing, just install silently.
# * If it's still in the Setup Assistant - do nothing, install silently, and
#   assume the user is still reading steps to use their computer and hasn't 
#   gotten to the macOS login window yet
# * If the user is root, we're probably on a macOS login window already.  Kill
#   the existing login window so we can reload the Jamf Connect login experience


# MIT License
#
# Copyright (c) 2021 Jamf Software

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
	

# Jamf Connect installer package name and where we've placed it with this 
#  metapackage
INSTALLER_FILENAME="/private/tmp/JamfConnect.pkg"

# If we're coming in from Jamf Pro, we should have been passed a target mount
#   point.  Otherwise, assume root directory is target drive.

TARGET_MOUNT=$3
if [ -z "$TARGET_MOUNT" ]; then 
	TARGET_MOUNT="/"
fi 

# Install the JamfConnect.pkg software
/usr/sbin/installer -pkg "$INSTALLER_FILENAME" -target "$TARGET_MOUNT"

# Now, you would be tempted to install the Jamf Connect launch agent here, but 
# don't! Install that as a separate policy.  You could potentially be launching 
# the Jamf Connect menu bar agent and its welcome screen for every user - 
# including the root user - which is the user that appears on the login screen 
# for the very first setup.  
#
# That would be annoying, and we want a beautiful experience for users.

# Remove the JamfConnect.pkg file
rm -f "$INSTALLER_FILENAME"

#####################################################################
# For zero touch enrollment only!  If an enrollment computer is on a slow
# network connection, the user may be presented with a standard macOS login
# window asking for a typed user name and password.  We must kill the 
# loginwindow IF and ONLY IF we're at the Setup Assistant user still.  If we 
# kill the loginwindow process while a user is actually using the computer, they
# will be unceremoniously kicked out of their current session.
#
# Thanks to Richard Pures for additions to this script,
#####################################################################

# For macOS Big Sur - Wait until they've decided that Apple Setup is Done.

while [ ! -f "/var/db/.AppleSetupDone" ]; do
	sleep 2
done

# Look for a user
loggedinuser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}' )
	
# If loginwindow, setup assistant or no user, then we're in an automated device 
#	enrollment environment.
if [[ "$loggedinuser" == "loginwindow" ]] || [[ "$loggedinuser" == "_mbsetupuser" ]] || [[ "$loggedinuser" == "root" ]] || [[ -z "$loggedinuser" ]];
	then
		# Now check to see if Setup Assistant is a running process.  
		# If Setup Assistant is running, we're not at the login screen yet. 
		# 	Exit and let macOS finish setup assistant and display the new Jamf 
		#	Connect login screen.
		[[ $( /usr/bin/pgrep "Setup Assistant" ) ]] && exit 0
		
		# Otherwise, kill the login window so it reloads and shows the Jamf 
		#	Connect login window instead.
		/usr/bin/killall -9 loginwindow
	fi

exit 0
