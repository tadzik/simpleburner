#!/usr/bin/env perl
# file: simpleburner.pl - it'll make Your burning cd's easier under the CLI environment
#  
#   Copyright 2009 Marcin Karpezo <sirmacik at gmail dot com>
#   license = GPLv3 
#   version = 0.1.4
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

use encoding 'utf8';

use strict;
use warnings;
use Getopt::Long;

my $burner = '/dev/sr0';       # Here You have to setup Your CD writer (if other than primary drive)

my $writer = 'wodim';           # You could set this options to work 
my $isomaker = 'genisoimage';   # with cdrtools instead of cdrkit

my $isomakeropts = '-U -o';     # Options used to make iso image
my $burnisoopts = "--eject -v --dev=$burner";     # Options used to burn iso image
my $isoname = '';
my $datadir = '';
my $burnspeed = '';
my $test = '';

my $burn = '';
my $makeiso = '';

GetOptions( "h|help" => \&help,       # print help
            "data=s" => \$datadir,    # set dir with data to burn
            "name=s" => \$isoname,    # set name of iso file
            "speed=s" => \$burnspeed, # set burn speed
            "test" => \$test,       # run test burn
            "burner=s" => \$burner,   # define writer other than default /dev/sr0
            "b|burn-only" => \$burn,  # run in burn-iso-only mode (name option must be defined)
            "m|makeiso" => \$makeiso); #run in make-iso-only mode 
            
sub help {
    print "Simpleburner is a program that will make Your burning cd's easier under the CLI environment 
        \nWARNING: To burn Your CD You must put Your files into default /tmp/burner directory or run burner with --data=/your/burndata/directory option
        \nWARNING: If You create iso image, by default  You'll find it in /tmp directory but You could set Your own location
        \nOPTIONS:
        -h|--help       - print this message
        --test          - run in test burn mode
        -b|--burn-only  - run without making iso image ('--name=/full/path/to/image.iso' option must be defined)
        -m|--makeiso    - make only iso image (without burn), by default Your image will be stored in /tmp directory
        --data=s        - set directory with data to burn (default /tmp/burner)
        --name=s        - set name of iso file (default cd.iso)
        --burner=s      - set burner to use (default /dev/sr0)\n";
} 

sub isoname {
    # Define name and location for iso image
    my ($name) = @_;
    $name ||= 'cd.iso';
    $name = "$name.iso" unless ($name =~ /.iso$/);

    unless ($name =~ m/\/*\//){     
        $isoname = "/tmp/$name";
    } else {
        $isoname = $name;
    }
}

sub makeiso {
    my ($dir) = @_;
    
    if ($dir) {
        $datadir = $dir;
    } else {
        $datadir = '/tmp/burner';
    };

    system("$isomaker $isomakeropts $isoname $datadir") and die "I can't burn Your cd! \n$!";
}

sub burniso {
    my ($opts);
    
    $burnisoopts = "$burnisoopts --dummy" if ($test); # run test burn if --t|test was set

    if ($burnspeed) {
        $opts = "$burnisoopts --speed=$burnspeed";
    } else {
        $opts = $burnisoopts;
    }
    system( "$writer $opts $isoname" )  and die "I can't write this image! \n$!";
}

isoname($isoname);
#print $isoname; # test print

if ($burn) {
    burniso();
} elsif ($makeiso) {
    makeiso( $datadir );
} else {
    makeiso( $isoname );
    burniso();
}

