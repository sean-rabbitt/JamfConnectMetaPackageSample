#!/bin/bash

# Generic Jamf Connect Prestage Enrollment installer package
# — SRABBITT May 22, 2020 12:52 PM
# Version 2 installer updated on September 29, 2020
# Updated 20NOV2020 - Added wait for .AppleSetupDone to see if we can make Big Sur happier.
# Updated 29JAN2021 - Changed the process to kill the login window based on if Setup Assistant
#	is still running and who the current console user is.  Code provided care of Richard Purves
#	with many thanks.
# Updated 15APR2022 - Removed the unneeded code to kill the login window if it is detected. 
#	This code is now native in the Jamf Connect 2.10 and greater installer package.


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
# Copyright (c) 2022 Jamf

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
	
exit 0
