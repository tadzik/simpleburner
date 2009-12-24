#!/usr/bin/env perl
# file: made to simplyfi CD/DVD burning under CLI
#  
#   Copyright 2009 Marcin Karpezo <sirmacik at gmail dot com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

use encoding 'utf8';

use strict;
use warnings;
use Getopt::Long;

my $writer = "";
my $isomaker = "";
my $datadir = "/tmp";
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
    print <<EOM;
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
            print("Failed! You must define --data option.\nRun -h|--help for more information.\n");
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
if ($burn) {
    &burniso;
} elsif ($make) {
    &makeiso;
    &optcheck;
} else {
    &optcheck;
    &makeiso;
    &burniso;
}

#TODO:
# ** Add audiocd burning 2009-10-26 21:33+0100
