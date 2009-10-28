#!/usr/bin/env perl
# file: made to simplyfi CD/DVD burning under CLI
#  
#   Copyright 2009 Marcin Karpezo <sirmacik at gmail dot com>
#   license = BSD 
#   version = 20091028 
#   All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, 
#       this list of conditions and the following disclaimer in the documentation 
#       and/or other materials provided with the distribution.
#     * Neither the name of the simpleburner nor the names of its contributors may 
#       be used to endorse or promote products derived from this software without 
#       specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
# OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
use encoding 'utf8';

use strict;
use warnings;
use Getopt::Long;

my $writer = "";
my $isomaker = "";
my $datadir = "";
my $isoname = "/tmp/cd.iso";
my $device = "/dev/sr0";
my $speed ="";
my $mode = "tao";
my $test = "";
my $burn = "";
my $make = "";

GetOptions("data=s" => \$datadir,
           "name=s" => \$isoname,
           "device=s" => \$device,
           "speed=s" => \$speed,
           "mode=s" => \$mode,
           "t|test" => \$test,
           "b|burn-only" => \$burn,
           "m|makeiso" => \$make,
           "h|help" => \&helpmsg,);

sub helpmsg {
    my $helpmsg = <<EOM;
Simpleburner, made to simplyfi CD/DVD burning under CLI
Usage: simpleburner [options]    
    
    -h, --help      Displays this message
        --data      Directory with data to burn
        --name      Path and/or name of iso image (by default /tmp/cd.iso)
        --device    Device to use (default /dev/sr0)
        --speed     Burning speed (by default it will be autodetected)
        --mode      Burning mode, available options are: TAO (default), DAO, SAO, RAW
    -t, --test      Run in test mode
    -b, --burn-only Run without making iso image
    -m, --makeiso   Make only iso image

Please send any bug reports to simpleburner-bugs\@googlegroups.com
EOM
    print($helpmsg);
    exit 0;
}
sub programcheck {
    print("Looking for cdrkit...");
    if (-e '/usr/bin/wodim' and -e '/usr/bin/genisoimage') {
        $writer = 'wodim';
        $isomaker = 'genisoimage';
        print("[OK!]\n");
    } elsif (-e '/usr/bin/cdrecord' and -e '/usr/bin/mkisofs') {
        print("Not found\nLooking for cdrtools...");
        $writer = 'cdrecord';
        $isomaker = 'mkisofs';
        print("[OK!]\n");
    } else {
        print("Not found: Please install cdrkit or cdrtools!\n");
        exit 1;
    }
}

sub optcheck {
    unless ($burn) {
        unless ($datadir) {
            print("Failed! You must deine --data option.\nRun -h|--help for more information.\n");
            exit 1;
        }
    } 
    unless ( -d $datadir) {
        print("Failed! Data directory '$datadir' does not exist.\n");
        exit 1;
    }
}

sub oldisock {
    print("Old iso file detected, delete it? [Y/n] "); my $reply=<STDIN>; chomp $reply;
    if ($reply eq "n") {
        print("Burn it? [Y/n] "); my $reply=<STDIN>; chomp $reply;
        if ($reply eq "n") {
            print("Stopped!\n");
            exit 1;
        } else {
            &burniso;
            exit 0;
        }
    } else {
        print("Deleting old iso file...");
        unlink($isoname);
        print("[OK]\n");
    }
}

sub makeiso {
    if (-e $isoname) {
        &oldisock;
    }
    print("Making iso image...\n");
    $datadir =~ s/\s+/\\ /g;
    my $command = "$isomaker -UR -quiet -allow-multidot -allow-leading-dots -iso-level 3 -o $isoname $datadir";
    system($command);
    unless ($? == "0") {
        die "Can't make iso file!\n";
    }
    print("[OK!]\nFile stored in $isoname\n");
}

sub burniso {
    print("Burning iso...\n");
    my $burnspeed = "";
    my $runtest = "";
    if ($speed) { 
        $burnspeed = " --speed=$speed";
    } elsif ($test) {
        $runtest = "--dummy";
    }
    my $command = "$writer  --eject -vs -$mode --dev=$device $burnspeed $runtest $isoname";
    system("$command > /dev/null"); 
    unless ($? == "0") {
        die "Can't burn disc!\n";
    }
    print("[OK!]\n");
}

if ($isoname =~ m/^~/) {
    $isoname =~ s/^~/$ENV{'HOME'}/;
}

if ($datadir =~ m/^~/) {
    $datadir =~ s/^~/$ENV{'HOME'}/;
}



&programcheck;
&optcheck;
if ($burn) {
    &burniso;
} elsif ($make) {
    &makeiso;
} else {
    &makeiso;
    &burniso;
}

#TODO:
# ** Add audiocd burning 2009-10-26 21:33+0100
