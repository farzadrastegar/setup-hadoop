#!/bin/bash
# USAGE: ./kickstart-config.bash <server-ip> <network-device>

# get input arguments in order
server_ip=$1
network_device=$2
rootpassword='$1$m94YPDA0$O4VvtW2eg0VIvff1pBKlG/'

cat << EOF
#version=DEVEL

# Install OS instead of upgrade
install

url --url=ftp://${server_ip}/pub

# System language
lang en_US.UTF-8

# Keyboard layouts
# old format: 
keyboard us
# new format: keyboard --vckeymap=us --xlayouts='us'

# Network information
network  --onboot yes --device ${network_device} --bootproto dhcp --noipv6

# Root password
rootpw --iscrypted "${rootpassword}"

# Firewall configuration
firewall --disabled

# System authorization information
authconfig --enableshadow --passalgo=sha512

selinux --disabled

# System timezone
timezone --utc Asia/Tehran

# System bootloader configuration
bootloader --location=mbr --append="rhgb quiet"

# Partition clearing information
clearpart --all --initlabel

# Disk partitioning information
#part /boot/efi --fstype="vfat" --size=200    --ondrive=sdb
#part /boot     --fstype="ext3" --size=1024   --ondrive=sdb
#part /grid/1   --fstype="ext3" --size=500000 --ondrive=sdb
#part /var      --fstype="ext3" --size=200000 --ondrive=sdb
#part /opt      --fstype="ext3" --size=100000 --ondrive=sdb
#part /usr/hdp  --fstype="ext3" --size=100000 --ondrive=sdb
#part /         --fstype="ext3" --size=82000  --ondrive=sdb
#part /drid/2   --fstype="ext3" --size=500000 --ondrive=sda

part / --fstype ext4 --size=5400
part /boot --fstype ext4 --size=100
part swap --size=2000



repo --name="pxe-repo" --baseurl=ftp://${server_ip}/pub --cost=100


%packages
@ Base
@ Printer Support
@ X Window System
@ GNOME
@ KDE
@ Mail/WWW/News Tools
@ DOS/Windows Connectivity
@ File Managers
@ Graphics Manipulation
@ Console Games
@ X Games
@ Console Multimedia
@ X multimedia support
@ Networked Workstation
@ Dialup Workstation
@ News Server
@ NFS Server
@ SMB (Samba) Connectivity
@ IPX/Netware(tm) Connectivity
@ Anonymous FTP Server
@ Web Server
@ DNS Name Server
@ Postgres (SQL) Server
@ Network Management Workstation
@ TeX Document Formatting
@ Emacs
@ Emacs with X windows
@ C Development
@ Development Libraries
@ C++ Development
@ X Development
@ GNOME Development
@ Kernel Development
@ Extra Documentation
AfterStep
AfterStep-APPS
AnotherLevel
ElectricFence
GXedit
ImageMagick
ImageMagick-devel
MAKEDEV
ORBit
ORBit-devel
SVGATextMode
SysVinit
WindowMaker
X11R6-contrib
XFree86-100dpi-fonts
XFree86
XFree86-3DLabs
XFree86-75dpi-fonts
XFree86-8514
XFree86-AGX
XFree86-FBDev
XFree86-I128
XFree86-ISO8859-2
XFree86-ISO8859-2-100dpi-fonts
XFree86-ISO8859-2-75dpi-fonts
XFree86-ISO8859-2-Type1-fonts
XFree86-ISO8859-9-100dpi-fonts
XFree86-ISO8859-9
XFree86-ISO8859-9-75dpi-fonts
XFree86-Mach32
XFree86-Mach64
XFree86-Mach8
XFree86-Mono
XFree86-P9000
XFree86-S3
XFree86-S3V
XFree86-SVGA
XFree86-VGA16
XFree86-W32
XFree86-XF86Setup
XFree86-Xnest
XFree86-Xvfb
XFree86-cyrillic-fonts
XFree86-devel
XFree86-doc
XFree86-libs
XFree86-xfs
Xaw3d
Xaw3d-devel
Xconfigurator
adjtimex
aktion
am-utils
anonftp
apache
apache-devel
apmd
arpwatch
ash
at
audiofile
audiofile-devel
aumix
authconfig
autoconf
autofs
automake
awesfx
basesystem
bash
bash2
bash2-doc
bc
bdflush
bin86
bind
bind-devel
bind-utils
binutils
bison
blt
bootparamd
byacc
bzip2
caching-nameserver
cdecl
cdp
chkconfig
chkfontpath
cleanfeed
comanche
compat-binutils
compat-egcs
compat-egcs-c++
compat-egcs-g77
compat-egcs-objc
compat-glibc
compat-libs
comsat
console-tools
control-center
control-center-devel
control-panel
cpio
cpp
cproto
cracklib
cracklib-dicts
crontabs
ctags
cvs
cxhextris
desktop-backgrounds
dev
dhcp
dhcpcd
dialog
diffstat
diffutils
dip
dosemu
dosemu-freedos
dump
e2fsprogs
e2fsprogs-devel
ed
ee
efax
egcs
egcs-c++
egcs-g77
egcs-objc
eject
elm
emacs
emacs-X11
emacs-el
emacs-leim
emacs-nox
enlightenment
enlightenment-conf
enscript
esound
esound-devel
etcskel
exmh
expect
ext2ed
faces
faces-devel
faces-xface
faq
fbset
fetchmail
fetchmailconf
file
filesystem
fileutils
findutils
finger
flex
fnlib
fnlib-devel
fortune-mod
freetype
freetype-devel
ftp
fvwm
fvwm2
fvwm2-icons
fwhois
gated
gawk
gd
gd-devel
gdb
gdbm
gdbm-devel
gdm
gedit
gedit-devel
genromfs
gettext
getty_ps
gftp
ghostscript
ghostscript-fonts
giftrans
gimp
gimp-data-extras
gimp-devel
gimp-libgimp
gimp-manual
git
glib
glib-devel
glib10
glibc
glibc-devel
glibc-profile
gmc
gmp
gmp-devel
gnome-audio
gnome-audio-extra
gnome-core
gnome-core-devel
gnome-games
gnome-games-devel
gnome-libs
gnome-libs-devel
gnome-linuxconf
gnome-media
gnome-objc
gnome-objc-devel
gnome-pim
gnome-pim-devel
gnome-users-guide
gnome-utils
gnorpm
gnotepad+
gnuchess
gnumeric
gnuplot
gperf
gpm
gpm-devel
gqview
grep
groff
groff-gxditview
gsl
gtk+
gtk+-devel
gtk+10
gtk-engines
gtop
guavac
guile
guile-devel
gv
gzip
gzip
hdparm
helptool
howto
howto-chinese
howto-croatian
howto-french
howto-german
howto-greek
howto-html
howto-indonesian
howto-italian
howto-japanese
howto-korean
howto-polish
howto-serbian
howto-sgml
howto-slovenian
howto-spanish
howto-swedish
howto-turkish
ical
imap
imlib
imlib-cfgeditor
imlib-devel
indent
indexhtml
inews
info
initscripts
inn
inn-devel
install-guide
intimed
ipchains
ipxutils
ircii
isapnptools
isicom
ispell
itcl
jed
jed-common
jed-xjed
joe
kaffe
kbdconfig
kdeadmin
kdebase
kdegames
kdegraphics
kdelibs
kdemultimedia
kdenetwork
kdesupport
kdeutils
kernel
kernel
kernel
kernel-BOOT
kernel-doc
kernel-headers
kernel-ibcs
kernel-pcmcia-cs
kernel-smp
kernel-smp
kernel-smp
kernel-source
kernelcfg
knfsd
knfsd-clients
korganizer
kpilot
kpppload
kterm
ld.so
ldconfig
less
lha
libPropList
libc
libelf
libghttp
libghttp-devel
libgr
libgr-devel
libgr-progs
libgtop
libgtop-devel
libgtop-examples
libjpeg
libjpeg-devel
libjpeg6a
libpcap
libpng
libpng-devel
libstdc++
libtermcap
libtermcap-devel
libtiff
libtiff-devel
libtool
libungif
libungif-devel
libungif-progs
libxml
libxml-devel
lilo
linuxconf
linuxconf-devel
logrotate
losetup
lout
lout-doc
lpg
lpr
lrzsz
lslk
lsof
ltrace
lynx
m4
macutils
mailcap
mailx
make
man
man-pages
mars-nwe
mawk
mc
mcserv
metamail
mgetty
mgetty-sendfax
mgetty-viewfax
mgetty-voice
mikmod
mingetty
minicom
mkbootdisk
mkdosfs-ygg
mkinitrd
mkisofs
mkkickstart
mktemp
mkxauth
mod_perl
mod_php
mod_php3
modemtool
modutils
mount
mouseconfig
mpage
mpg123
mt-st
mtools
multimedia
mutt
mxp
nag
nc
ncftp
ncompress
ncpfs
ncurses
ncurses-devel
ncurses3
net-tools
netcfg
netkit-base
netscape-common
netscape-communicator
netscape-navigator
newt
newt-devel
nmh
nscd
ntsysv
open
p2c
p2c-devel
pam
passwd
patch
pciutils
pdksh
perl
perl-MD5
pidentd
pilot-link
pilot-link-devel
pine
playmidi
playmidi-X11
pmake
pmake-customs
popt
portmap
postgresql
postgresql-clients
postgresql-devel
ppp
printtool
procinfo
procmail
procps
procps-X11
psacct
psmisc
pump
pwdb
pygnome
pygtk
python
python-devel
python-docs
pythonlib
qt
qt-devel
quota
raidtools
rcs
rdate
rdist
readline
readline-devel
redhat-logos
redhat-release
rgrep
rhl-alpha-install-addend-en
rhl-getting-started-guide-en
rhl-install-guide-en
rhmask
rhs-hwdiag
rhs-printfilters
rhsound
rmt
rootfiles
routed
rpm
rpm-devel
rsh
rsync
rusers
rwall
rwho
rxvt
sag
samba
sash
screen
sed
sendmail
sendmail-cf
sendmail-doc
setconsole
setserial
setup
setuptool
sgml-tools
sh-utils
shadow-utils
shapecfg
sharutils
slang
slang-devel
sliplogin
slocate
slrn
slrn-pull
sndconfig
sox
sox-devel
specspo
squid
stat
statserial
strace
svgalib
svgalib-devel
swatch
switchdesk
switchdesk-gnome
switchdesk-kde
symlinks
sysklogd
talk
taper
tar
tcl
tclx
tcp_wrappers
tcpdump
tcsh
telnet
termcap
tetex
tetex-afm
tetex-doc
tetex-dvilj
tetex-dvips
tetex-latex
tetex-xdvi
texinfo
textutils
tftp
time
timeconfig
timed
timetool
tin
tix
tk
tkinter
tksysv
tmpwatch
traceroute
transfig
tree
trn
trojka
tunelp
ucd-snmp
ucd-snmp-devel
ucd-snmp-utils
umb-scheme
unarj
units
unzip
urlview
urw-fonts
usermode
usernet
utempter
util-linux
uucp
vim-X11
vim-common
vim-enhanced
vim-minimal
vixie-cron
vlock
w3c-libwww
w3c-libwww-apps
w3c-libwww-devel
wget
which
wmakerconf
wmconfig
words
wu-ftpd
x11amp
x11amp-devel
x3270
xanim
xbanner
xbill
xboard
xboing
xchat
xcpustate
xdaliclock
xdosemu
xearth
xfig
xfishtank
xfm
xgammon
xinitrc
xjewel
xlispstat
xloadimage
xlockmore
xmailbox
xmorph
xntp3
xosview
xpaint
xpat2
xpdf
xpilot
xpm
xpm-devel
xpuzzles
xrn
xscreensaver
xsysinfo
xtoolwait
xtrojka
xwpick
xxgdb
yp-tools
ypbind
ypserv
ytalk
zgv
zip
zlib
zlib-devel
zsh

%end

EOF
exit 0
