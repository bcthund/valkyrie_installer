# valkyrie_installer
## Description
This is a script I created for a system restore procedure during a fresh install when upgrading from Ubuntu 18.04 to Kubuntu 20.04.

Valkyrie is a gui for valgrind provided by the makers of valgrind. However due to its dependence on qt4 it doesn't have a package in apt and does not compile without adding qt4 support. I also had multiple files that I had to add includes to so it would compile. So although the script does allow you to pull the latest from subversion, it likely will not compile and you will have to use the included snapshot of Valkyrie.

See also:
  * [fresh_install](https://github.com/bcthund/fresh_install)

## Usage
<pre>
Usage: valkyrie.sh &lt;options&gt;

Options:
  -h, --help            show this help message and exit
  -v, --verbose         print commands being run before running them
  -d, --debug           print commands to be run but do not execute them
</pre>

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
