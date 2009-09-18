#!/usr/bin/env python
#-*- coding: utf-8 -*-
#
#   Copyright 2009 Marcin Karpezo <sirmacik at gmail dot com>
#   license = GPLv3 
#   version = 0.6
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
import sys
import subprocess
from optparse import OptionParser

def programcheck():
    print "Looking for cdrkit..."
    if os.path.exists('/usr/bin/wodim') and os.path.exists('/usr/bin/genisoimage'):
        globals() ["writer"] = 'wodim'
        globals() ["isomaker"] = 'genisoimage'
        print "[OK]"

    else:
        print >>sys.stderr, "Not found\nLooking for cdrtools..."
        if os.path.exists('/usr/bin/cdrecord') and os.path.exists('/usr/bin/mkisofs'):
            globals() ["writer"] = 'cdrecord'
            globals() ["isomaker"] = 'mkisofs'
            print "[OK]"
        else:
            print >>sys.stderr, "Not found: Please install cdrkit or cdrtools!"
            sys.exit(1)
def makeiso():
    print "Making iso image..."
    command = "%s -U -o %s %s" % (isomaker, isoname, datadir)
    makeiso = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True).communicate()[0]
    if makeiso:
        print >>sys.stderr, "Failed!"
        sys.exit(1)
    else:
        print "[OK]"
def burniso():
    print "Burning iso..."
    if speed:
        burnspeed = " --speed=%s" % speed
    else:
        burnspeed = ''
    if test == "True":
        runtest = ' --dummy'
    else:
        runtest = ''
    command = "%s --eject -v --dev=%s %s %s %s" % (writer, device, burnspeed, runtest, isoname)
    burniso = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True).communicate()[0]
    if burniso:
        print >>sys.stderr, "Failed!"
        sys.exit(1)
    else:
        print "[OK]"
if __name__=="__main__":
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("--data", dest="datadir",
                      help="set directory with data to burn")
    parser.add_option("--name", dest="isoname",
                      help="set path and/or name of iso image")
    parser.add_option("--device", dest="device", default="/dev/sr0",
                      help="set device to use (default /dev/sr0)")
    parser.add_option("--speed", dest="speed",
                      help="set burn speed (by default it will be autodetected)")
    parser.add_option("-t", "--test", action="store_true", dest="test", default= False ,
                      help="run in test burn mode")
    parser.add_option("-b", "--burn-only", action="store_true", dest="burn", default=False,
                      help="run without making iso image ('--name' option must be defined)")
    parser.add_option("-m", "--makeiso", action="store_true", dest="make", default=False,
                      help="make only iso image (by default image will be stored in current directory)")

    (options, args) = parser.parse_args()
    datadir = options.datadir
    isoname = options.isoname
    device = options.device
    speed = options.speed
    test = options.test
    burn = options.burn
    make = options.make

    print burn, make
    programcheck()

    if burn == True:
        burniso()
    elif make == True:
        makeiso()
    else:
        makeiso()
        burniso()
    
    
