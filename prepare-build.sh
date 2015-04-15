#!/bin/sh
# Copyright (C) 2015 Florent Revest <revestflo@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

ROOTDIR=`pwd`

# Fetch sources
mkdir -p sources build/conf
if [ ! -d sources/poky ] ; then
    git clone git://git.yoctoproject.org/poky.git sources/poky
fi
if [ ! -d sources/meta-openembedded ] ; then
    git clone git://git.openembedded.org/meta-openembedded sources/meta-openembedded
fi
if [ ! -d sources/meta-smartphone ] ; then
    git clone git://github.com/shr-distribution/meta-smartphone sources/meta-smartphone
fi
if [ ! -d sources/meta-boot2efl ] ; then
    git clone git://github.com/FlorentRevest/meta-boot2efl sources/meta-boot2efl
fi
if [ ! -d sources/meta-radxa-hybris ] ; then
    git clone git://github.com/FlorentRevest/meta-radxa-hybris sources/meta-radxa-hybris
fi

rm -rf sources/meta-smartphone/meta-android/recipes-android/image-utils/
rm -rf sources/meta-smartphone/meta-android/recipes-android/brcm-patchram-plus/
rm -rf sources/meta-smartphone/meta-android/recipes-android/rpc/android-rpc_git.bb

# Create local.conf and bblayers.conf
if [ ! -e $ROOTDIR/build/conf/local.conf ]; then
    cat >> $ROOTDIR/build/conf/local.conf << EOF
MACHINE ??= "radxa-hybris"
DISTRO ?= "poky"
PACKAGE_CLASSES ?= "package_ipk"

CONF_VERSION = "1"
BB_DISKMON_DIRS = "\\
    STOPTASKS,\${TMPDIR},1G,100K \\
    STOPTASKS,\${DL_DIR},1G,100K \\
    STOPTASKS,\${SSTATE_DIR},1G,100K \\
    ABORT,\${TMPDIR},100M,1K \\
    ABORT,\${DL_DIR},100M,1K \\
    ABORT,\${SSTATE_DIR},100M,1K" 
PATCHRESOLVE = "noop"
USER_CLASSES ?= "buildstats image-mklibs image-prelink"
EXTRA_IMAGE_FEATURES = "debug-tweaks"
EOF
fi

if [ ! -e $ROOTDIR/build/conf/bblayers.conf ]; then
    cat >> $ROOTDIR/build/conf/bblayers.conf << EOF
LCONF_VERSION = "6"

BBPATH = "\${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \\
  $ROOTDIR/sources/poky/meta \\
  $ROOTDIR/sources/poky/meta-yocto \\
  $ROOTDIR/sources/poky/meta-yocto-bsp \\
  $ROOTDIR/sources/meta-smartphone/meta-android \\
  $ROOTDIR/sources/meta-boot2efl \\
  $ROOTDIR/sources/meta-radxa-hybris \\
  "
BBLAYERS_NON_REMOVABLE ?= " \\
  $ROOTDIR/sources/poky/meta \\
  $ROOTDIR/sources/poky/meta-yocto \\
  $ROOTDIR/sources/poky/meta-yocto-bsp \\
  $ROOTDIR/sources/meta-smartphone/meta-android \\
  $ROOTDIR/sources/meta-boot2efl \\
  $ROOTDIR/sources/meta-radxa-hybris \\
  "
EOF
fi

# Init build env
cd sources/poky
. ./oe-init-build-env $ROOTDIR/build > /dev/null

cat << EOF
Welcome to the Boot2EFL compilation script.

If you meet any issue you can report it to the project's github page:
    https://github.com/FlorentRevest/boot2efl

You can now run the following command to get started with the compilation:
    bitbake boot2efl

Have fun!
EOF
