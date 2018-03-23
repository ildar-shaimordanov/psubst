## Psubst'd drive are not mapped ##

On some systems psubst'd drives are not mapped if psubst was run under privileges of regular users. It reguires to be run twice as Administrator and a regular user. See a workaround in [issue 4](https://code.google.com/p/psubst/issues/detail?id=4):

> First Run As Admin:
```
  psubst Z: "\\192.168.1.193\raid" /P
```
> That will create the registry entry.

> Then as normal user:
```
  psubst Z: "\\192.168.1.193\raid"
```

## BSOD ##

[issue 5](https://code.google.com/p/psubst/issues/detail?id=5) had been created to inform that sometimes usage of the tool led to BSOD. In fact this is not direct influence of different programs each other. Moreover, it may be the specific behaviour of a single program. From the description of the issue we can see that BSOD appears only after applying this script, reboot and login.

Harald Eiermann said:
> I faced a BSOD when using the script on a system with Trend Micro 10.x virus scan. It worked with Trend Micro virus scanner version 8.x before.

It seems that Trend Micro 10.x has troubles working with permanently subst'd drives. This presumption can be checked by adding manually an entry to the Registry (not using the script) and rebooting/logging in. If BSOD appears again this will be proof of it.

## LABELING ##

[issue 6](https://code.google.com/p/psubst/issues/detail?id=6). Once created a subst'ed drive has the same label and the same total, used and free sizes. This is not bug of the `SUBST`/`PSUBST` tools but feature of Windows when subst'ed drives inherit properties from the original drive.

They inform that this issue can be solved by adding the certain key to the Windows Registry:

Create the following registry key for changing the drive label
```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\X\DefaultLabel 
```

Create the following registry key for changing the drive icon
```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\X\DefaultIcon 
```

`X` refers for the real drive letter. Populate the default value in each key with the particular values and restart the system to apply changes.

### Solution from search ###
See for details the following link: http://www.digwin.com/cant-rename-subst-drive-in-ultimate-32bit

### Another user-defined solution ###
[hikaruandkaoru](http://code.google.com/u/116624949029883137816/) wrote in the [issue 6](https://code.google.com/p/psubst/issues/detail?id=6):

> i however made a temporary workaround, which while being effective, i have no idea if it can limit functionality.

> If for example i have: `O:\Folder1 mapped to U:` I shared `O:\Folder1` to my user with full access (that way only i can manipulate it freely)

> Then i mapped a network drive to `U:` using `\\localhost\Folder1`. This allows you to manipulate the defaultLabel and DefaultIcon registries as well as being able to RightClick - Rename the drives. It also works without internet connection since it's connecting to localhost. And the only difference i found was that it appears under Network Locations instead of Hard Disk Drives. The only problem might be if you want to map an unsharable location.

> Steps for newbies:
    1. Right click on folder you want to map
    1. Properties
    1. Sharing Tab
    1. Share Button
    1. Here make sure that your use has Read/Write access and that any other users have no rights (do not appear). Administrators are ok.
    1. Share Button
    1. In explorer, in the location bar, type: \\localhost
    1. Right click the folder you just shared
    1. Map network drive...
    1. Select the letter you want
    1. Finish Button

## Can't SUBST a path ##
If you try to SUBST a path to the existing drive you will get two different error messages:

The drive `G:` is a physical or logical drive name
```
Invalid parameter - G:
```

The specified drive is a substituted drive
```
Drive already SUBSTed
```

~~The [issue 8](https://code.google.com/p/psubst/issues/detail?id=8) describes this problem. Anyway, you have to specify another name for substituted paths.~~

The real problem with the [issue 8](https://code.google.com/p/psubst/issues/detail?id=8) had to do with another reason that was fixed yet. Anyway, if you meet the messages as described above be sure that your system doesn't use the drive name you want to substitute.

## Map network path with different credential for system account? ##

[Madnik7](http://code.google.com/u/Madnik7@gmail.com/) has asked ([issue 9](https://code.google.com/p/psubst/issues/detail?id=9)):
> can I map network path for system account? The problem is that sytem account does not have access to network resource without especifying a credential.

Commonly, they don't recommend use SUBST for mapping network paths. There is an appropriate tool NET USE. Nevertheless, there is interesting discussion that has to do with this issue (see this forum http://www.dostips.com/forum/viewtopic.php?f=3&t=5258). It is based on the undocumented features of SUBST command given at http://ss64.com/nt/subst.html :

> if a drive is substed using characters other than A-Z ($,#, :, !, 0-9) it will not appear in Windows Explorer or in the drives reported by SUBST.

So we could use the following workaround solution:
```
subst #: \\servername\share
subst Z: #:\
```

## Missing the final parenthesis ) of the path after restart ##

[jpach4](https://code.google.com/u/110168451143980461231/) has informed about the bug when the folder contains final parenthesis ([issue 10](https://code.google.com/p/psubst/issues/detail?id=10)).

This bug has been fixed in the revision [r36](https://code.google.com/p/psubst/source/detail?r=36) and the new version 2.6 is available for downloading from the [FossHub Downloads](http://code.fosshub.com/psubst/downloads) page.

## Mapping `A:` or `B:` to a folder on another drive

As it was mentioned in the [issue 16](https://github.com/ildar-shaimordanov/psubst/issues/16), there is trouble in mapping the drives `A:` or `B:` to a folder on another drive. @bourbongoat said that this issue can be solved removing the registry key for the particular drives:

> Deleting the registry key for the b:\ drive will fix it, however. I've also reproduced the issue with the a:\ drive, but others seem to work without issue.

