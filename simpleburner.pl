#!/usr/bin/env perl
# file: made to simplify CD/DVD burning under CLI
#  
#   Copyright 2009, 2010 Marcin Karpezo <sirmacik at gmail dot com>
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

my ($writer, $isomaker, $speed, $test, $burn, $make);
my $datadir = "/tmp";
my $isoname = "~/cd.iso";
my $device = "/dev/sr0";
my $mode = "tao";

GetOptions("data=s" => \$datadir,
           "name=s" => \$isoname,
           "device=s" => \$device,
           "speed=s" => \$speed,
           "mode=s" => \$mode,
           "t|test" => \$test,
           "b|burn-only" => \$burn,
           "m|makeiso" => \$make,
           "h|help" => \&helpmsg,);

sub warning {
    print <<END;
simpleburner, made to simplify CD/DVD burning under CLI

simpleburner Copyright (C) 2009, 2010 Marcin Karpezo 
This program comes with ABSOLUTELY NO WARRANTY. 
This is free software, and you are welcome 
to redistribute it under certain conditions.
For details see COPYING file.

END
}

sub helpmsg {
    warning();
    print <<EOM;
Simpleburner, made to simplify CD/DVD burning under CLI
Usage: simpleburner [options]    
    
    -h, --help      Displays this message
        --data      Directory with data to burn
        --name      Path and/or name of iso image (by default ~/cd.iso)
        --device    Device to use (default /dev/sr0)
        --speed     Burning speed (by default it will be autodetected)
        --mode      Burning mode, available options are: TAO (default), DAO, SAO, RAW
    -t, --test      Run in test mode
    -b, --burn-only Run without making iso image
    -m, --makeiso   Make only iso image

Please send any bug reports or feuture requests to simpleburner-bugs\@googlegroups.com
EOM
    exit 0;
}

sub try {
    print shift;
    shift();
    print shift || "[OK!]\n";
}

sub programcheck {
    try "Looking for cdrkit...", do {
        if (-e '/usr/bin/wodim' and -e '/usr/bin/genisoimage') {
            $writer = 'wodim';
            $isomaker = 'genisoimage';
        } elsif (-e '/usr/bin/cdrecord' and -e '/usr/bin/mkisofs') {
            print("Not found\nLooking for cdrtools...");
            $writer = 'cdrecord';
            $isomaker = 'mkisofs';
        } else {
            die("Not found: Please install cdrkit or cdrtools!\n");
        }
    };
}

sub optcheck {
    unless ($burn or $datadir) {
        die("Failed! You must define --data option.\n"
            ."Run -h|--help for more information.\n");
    } 
    unless (-d $datadir) {
        die("Failed! Data directory '$datadir' does not exist.\n");
    }
}

sub makeiso {
    if (-e $isoname) {
        oldisock();
    }
    try "Making iso image", do {
        $datadir =~ s/\s+/\\ /g;
        my $command = "$isomaker -UR -quiet -allow-multidot "
                      ."-allow-leading-dots -iso-level 3 "
                      ."-o $isoname $datadir";
        system($command) or die "Can't make iso file!\n";
    };
    print("File stored in $isoname\n");
}

sub burniso {
    try "Burning iso...", do {
        my ($burnspeed, $runtest);
        if ($speed) {
            $burnspeed = " --speed=$speed";
        } elsif ($test) {
            $runtest = "--dummy";
        }
        my $command = "$writer --eject -vs -$mode --dev=$device "
                     ."$burnspeed $runtest $isoname";
        system("$command > /dev/null") or die "Can't burn disc!\n";
    };
}

sub oldisock {
    print("Old iso file detected, delete it? [Y/n] ");
    my $reply = <STDIN>; chomp $reply;
    if ($reply eq "n") {
        print("Burn it? [Y/n] ");
        my $reply = <STDIN>; chomp $reply;
        if ($reply eq "n") {
            die("Stopped!\n");
        } else {
            burniso();
            exit 0;
        }
    } else {
        try "Deleting old iso file...", { unlink $isoname };
        makeiso();
        burniso();
    }
}

$isoname =~ s/^~/$ENV{'HOME'}/;
$datadir =~ s/^~/$ENV{'HOME'}/;

warning();
programcheck();
if ($burn) {
    burniso();
} elsif ($make) {
    makeiso();
    optcheck();
} else {
    optcheck();
    oldisock();
}

#TODO:
# * Delete of iso image after burning, nie, 3 sty 2010, 19:04:50 CET
# * CD-RW cleaning, nie, 3 sty 2010, 19:05:14 CET
# ** Add audiocd burning 2009-10-26 21:33+0100
