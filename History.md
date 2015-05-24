### History ###

2014/09/17 - Version 2.6 Stable.
Fixed [Issue 10](https://code.google.com/p/psubst/issues/detail?id=10): Missing the final parenthesis ) of the path after restart

2013/04/07 - Version 2.5 Stable.
The  [issue 8](https://code.google.com/p/psubst/issues/detail?id=8)  was fixed (troubles with special characters in substituted paths).

2009/03/06 - Version 2.4 Stable.
Earlier, to see persistent drives the `REG QUERY` command was made to the temporary file. Now this is making via pipes without any files.

2009/01/27 - Version 2.3 Stable.
Separate view for the SUBSTed disks and persistent SUBSTed disks. Thus `PSUBST /P` shows persistent disks only.

2008/09/22 - Version 2.2 Stable.
The minor bug was fixed: Unable to remove record from the registry when drive was unsubstituted already.

2008/09/04 - Version 2.1 Stable.
Tests has been provided and it works properly.

2008/09/02 - Version 2.0 Beta.
Now the REG utility is used instead of the REGEDIT.

2008/09/02 - Version 1.2.
The problem of quoted arguments in the `IF "%*" == ""` construction was fixed.

2008/08/31 - Version 1.1.
Minor changes (the more accurate init of vars, unified names of vars).

2008/08/30 - The first release.