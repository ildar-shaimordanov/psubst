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
  * [How does this work?](#how-does-this-work)
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

So to reach targets in this folder it does not need to type the full path or go over  a tree of folders in the Explorer window. To select the `Z:` drive is enough.

## Do we need it? ##

There is several certain examples when this feature is needful:

* Temporary stub when the physical drive is missing;
* Operational system limitation for the size of filename (256 characters);
* Working of some application within own space;
* Emulation of other operational systems.

## How does this work? ##

Create new virtual drive:

```
subst Z: "C:\Documents and Settings\All Users\Shared Documents" 
```

Delete virtual drive:

```
subst Z: /D 
```

Print a list of existing drives:

```
subst 
```

## Shortcomings ##

### Indefinite format ###

There is strong agreement about a correct typing of the substituted path:

1. a path should not be trailed by a backslash;
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

However restart of a system destroys a virtual disk. What to do? A disk can be created after startup. But what to do, when a disk is needed on early steps of a startup? For example, to run services? There is system feature to start a virtual disk from the system registry:

```
REGEDIT4 

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices] 
"Z:"="\\??\\C:\\Documents and Settings\\All Users\\Shared Documents" 
```

It is enough to create a text file with the extension `.REG` and run it. When the next starting up of a system, the virtual disk will be exist at logon. It needs to define a name of disk and path. Note that each backslash in the path is doubled.

### Can it be joined? ###

Answer is yes! This article is the result of the work devoted to availability of joining both features. The batch script was developed for cover problems described earlier. Also it adds a lot of owned features.

## Overview of the new features ##

### Standard ###

As well as the standard `SUBST` command this script named as `PSUBST.BAT` implements all standard features of the command.

Create a disk:

```
psubst drive1: drive2:path 
```

Delete a disk:

```
psubst drive1: /D 
```

Print of existing disks:

```
psubst 
```

### Extended ###

Typing the `/P` argument you run the script with the extended features to work with persistent virtual disks.

Create a persistent virtual drive with saving in the registry:

```
psubst drive1: drive2:path /P 
```

Create a virtual drive reading about it from the registry:

```
psubst drive1: /P 
```

Delete a drive and wipe out a record from the registry:

```
psubst drive1: /D /P 
```

Print all virtual persistent drives (read from the registry)

```
psubst /P 
```

### Additional features ###

Great advantage of the script is independency of existence or lack of the trailing backslashes. It means that incorrect examples described earlier in this article will work always – incorrect input arguments will be transformed to the required format and the command will execute substitution successfully. Nevertheless the standard command works with the slashes in a path correctly, the script transforms these to backslashes usual in Windows.

### New shortcomings ###

Are there owned shortcomings? Exactly! There are:

* this is batch script and it works slower than binary analog;
* there is probability to run script twice with different arguments and disturb results of both;
* there is probability to break a script execution when disk have been created but the registry is not updated. But there are so little things.

## How to install? ##

### Simple way ###

Download the archive following by the download link, unpack it or checkout the source and put the single file to comfortable place in your hard disk.

### As a Chocolatey package ###

Time ago I was asked to publish the tool as the Chocolatey package (see [issue 14](https://github.com/ildar-shaimordanov/psubst/issues/14)). If you use Chocolatey actively, you can install it as follows:

```
choco install psubst [--version=2.6.2]
```

Also you can find it by this link: https://chocolatey.org/packages/psubst.

## Related links ##

* [SUBST home](http://technet.microsoft.com/en-us/library/bb491006.aspx)
* [Persistent subst for NT-clones (by Alexander Telyatnikov)](http://alter.org.ua/en/docs/win/persist_subst/)
* [C++ coded PSUBST (by Alexander Telyatnikov)](http://alter.org.ua/en/soft/win/psubst/)
* [Overview of file systems FAT, HPFS and NTFS (Microsoft knowledge base page in Russian)](http://support.microsoft.com/kb/100108)
* [How NTFS Works](http://technet.microsoft.com/en-us/library/cc781134.aspx)
* [The same text in Russian](http://debugger.ru/articles/psubst)
