# valkyrie_installer
## Description
This is a script I created for a system restore procedure during a fresh install when upgrading from Ubuntu 18.04 to Kubuntu 20.04.

Valkyrie is a gui for valgrind provided by the makers of valgrind. However due to its dependence on qt4 it doesn't have a package in apt and does not compile without adding qt4 support. I also had multiple files that I had to add includes to so it would compile. So although the script does allow you to pull the latest from subversion, it likely will not compile and you will have to use the included snapshot of Valkyrie.

See also:
  * [fresh_install](https://github.com/bcthund/fresh_install)

## Usage
```chmod +x valkyrie.sh```  
<br>
<u>**Live run:**</u>  
This will prompt you with a series of questions and perform the actions, making changes to your filesystem.  
```./valkyrie.sh```  
<br>
<u>**Debug:**</u>  
This will prompt you with a series of questions but will not actually perform them. It will echo the command that would be run so you can do a dry run first.  
```./valkyrie.sh debug```

## Packages for Reference (installed automatically):
<u>**All Dependencies**</u>
<pre>
  libqt4-dev
  ? possibly others
</pre>

## Addons
<pre>
  none
</pre>
