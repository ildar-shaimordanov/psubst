# Persistent SUBST command #

* [History](History.md)
* [Issues and troubleshooting](IssuesAndTroubleshooting.md)
* [Download](https://github.com/ildar-shaimordanov/psubst/releases)

<!-- md-toc-begin -->
# Table of Content
* [Persistent SUBST command](#persistent-subst-command)
  * [Abstract](#abstract)
  * [Divide and power](#divide-and-power)
  * [Do we need it?](#do-we-need-it)
  * [How does it work?](#how-does-it-work)
  * [Shortcomings](#shortcomings)
    * [Indefinite format](#indefinite-format)
    * [Inconstancy](#inconstancy)
    * [Can it be joined?](#can-it-be-joined)
  * [Overview of the new features](#overview-of-the-new-features)
    * [Standard](#standard)
    * [Extended](#extended)
    * [Additional features](#additional-features)
    * [New shortcomings](#new-shortcomings)
  * [How to install?](#how-to-install)
    * [Simple way](#simple-way)
    * [As a Chocolatey package](#as-a-chocolatey-package)
  * [Related links](#related-links)
<!-- md-toc-end -->

## Abstract ##

_Associates a path with a drive letter and extends the standard SUBST command allowing to create persistent substituted drives between startups._

## Divide and power ##

Since oldest times in Windows there is admirable feature to map some path with name of a virtual drive using the `SUBST` command. This feature simplifies an access to objects on a disk. It means a usage of name of a virtual drive instead of a long path. For example, the following command is used to create virtual drive `Z` for the path `C:\Documents and Settings\All Users\Shared Documents`:

```
subst Z: "C:\Documents and Settings\All Users\Shared Documents"
```

So to reach targets in this folder it does not need to type the full path or go over a tree of folders in the Explorer window. To select the `Z:` drive is enough.

## Do we need it? ##

There are several certain examples when this feature is useful:

* Temporary stub when the physical drive is missing;
* Operational system limitation for the size of filename (for example, 256 characters);
* Working of some application within own space;
* Emulating other operational systems.

## How does it work? ##

Print the list of existing drives:

```
subst
```

Create new virtual drive:

```
subst Z: "C:\Documents and Settings\All Users\Shared Documents"
```

Delete the virtual drive:

```
subst Z: /D
```

## Shortcomings ##

### Indefinite format ###

There are strict conventions on correct typing the substituted path:

1. the path should not be trailed by a backslash;
1. the root path should be ended by a backslash.

For example, these are correct

```
subst Z: "C:\Documents and Settings\All Users\Shared Documents"
subst Z: C:\
```

But these are incorrect:

```
subst Z: "C:\Documents and Settings\All Users\Shared Documents\"
subst Z: C:
```

### Inconstancy ###

However restart of the system destroys the virtual disk. What to do? A disk can be created after startup. But what to do, when the disk is required on early steps of the startup? For example, to run services? There is system feature to establish virtual disks from the system registry:

```
REGEDIT4

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices]
"Z:"="\\??\\C:\\Documents and Settings\\All Users\\Shared Documents"
```

It is enough to create a text file with the extension `.REG` and run it. When the next system starting, the virtual disk will be established. It needs to define the name of the disk and path. Note that each backslash in the path is doubled.

### Can it be joined? ###

Answer is yes! This article is the result of the work devoted to availability of joining both features. The batch script was developed to cover problems described earlier. Also it adds a lot of owned features.

## Overview of the new features ##

### Standard ###

As well as the standard `SUBST` command this script named as `PSUBST.BAT` implements all standard features of the command.

Print all virtual drives:

```
psubst
```

Create the virtual drive:

```
psubst drive1: drive2:path
```

Delete the virtual drive:

```
psubst drive1: /D
```

### Extended ###

Typing the `/P` or `/PF` argument you run the tool with the extended features to work with persistent virtual disks:

* `/P` stands for creating, deleting or displaying persistent drives;
* `/PF` stands for creating and deleting persistent drives using elevated privileges; it can be useful for managing persistent drives by non-administrative users.

Print all virtual persistent drives (read from the registry)

```
psubst /P
```

Restore a virtual drive from the persistent drive, if any:

```
psubst drive1: /P
```

In the following commands the option `/P` can be replaced with the option `/PF` to elevate privileges.

Create the persistent virtual drive with saving its persistency in the registry:

```
psubst drive1: drive2:path /P
```

Delete the persistent drive from the registry:

```
psubst drive1: /D /P
```

### Additional features ###

Great advantage of the tool is independency of existence or lack of the trailing backslashes. It means that incorrect examples described earlier in this article will work always – incorrect input arguments will be transformed to the required format and the command will execute substitution successfully. Nevertheless the standard command works with the slashes in a path correctly, the script transforms these to backslashes usual in Windows.

### New shortcomings ###

Are there own shortcomings? Yes, a bit of them! There are:

* this is batch script and it works a bit slower than binary analog;
* there is quite weak probability to run the script twice with different arguments and disturb results of both;
* there is weak probability to break the script execution when disk is already created but the registry is not updated yet. To be honest, it's not lack of this script because managing the drives and updating the registry are two separate independednt actions.

## How to install? ##

### Simple way ###

Download the archive following by the download link, unpack it or checkout the source and put the single file to comfortable place in your hard disk.

### As a Chocolatey package ###

Time ago I was asked to publish the tool as the Chocolatey package (see [issue 14](https://github.com/ildar-shaimordanov/psubst/issues/14)). If you use Chocolatey actively, you can install it as follows:

```
choco install psubst
```

Also you can find it by this link: https://chocolatey.org/packages/psubst.

## Related links ##

* [SUBST home](http://technet.microsoft.com/en-us/library/bb491006.aspx)
* [Persistent subst for NT-clones (by Alexander Telyatnikov)](http://alter.org.ua/en/docs/win/persist_subst/)
* [C++ coded PSUBST (by Alexander Telyatnikov)](http://alter.org.ua/en/soft/win/psubst/)
* [Overview of file systems FAT, HPFS and NTFS (Microsoft knowledge base page in Russian)](http://support.microsoft.com/kb/100108)
* [How NTFS Works](http://technet.microsoft.com/en-us/library/cc781134.aspx)
* [The same text in Russian](http://debugger.ru/articles/psubst)
