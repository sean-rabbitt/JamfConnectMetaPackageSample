# JamfConnectMetaPackageSample
 A flat package installer for Jamf Connect you can use as a seed for 
	customizing a package in Jamf Composer
	
Some MDMs cannot install multiple packages at a prestage enrollment.
Some versions of macOS may show the login window before Jamf Connect has a
	chance to install.
This package example fixes that problem.

We are wrapping the JamfConnect.pkg in this package with additional branding
images, scripts, help files, etc. for a zero touch enrollment.

Lastly, after all is installed, we check to see what the current state of 
the user experience is showing

* If it's in the user space, we assume that the user is in Finder and working
  on the computer - do nothing, just install silently.
* If it's still in the Setup Assistant - do nothing, install silently, and
  assume the user is still reading steps to use their computer and hasn't 
  gotten to the macOS login window yet
* If the user is root, we're probably on a macOS login window already.  Kill
  the existing login window so we can reload the Jamf Connect login experience

Simply drag and drop your assets and the latest version of JamfConnect.pkg
into the file, sign with an appropriate certificate for distribution,
and upload to your Jamf Pro file share distribution point for deployments.