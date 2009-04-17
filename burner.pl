#!/usr/bin/env perl
# file: burner.pl - it'll make Your burning cd's easier under the CLI environment
#  
#   Copyright 2009 Marcin Karpezo <sirmacik at gmail dot com>
#   license = GPLv3 
#   version = 0.1
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
use 5.010; 

my $burner = '/dev/cdrw';       # Here You have to setup Your CD writer (if other than primary device)

my $writer = 'wodim';           # You could set this options to work 
my $isomaker = 'genisoimage';   # with cdrtools instead of cdrkit

my $isomakeropts = '-U -o';     # Options used to make iso image
my $burnisoopts = "--eject -v --dev=$burner";     # Options used to burn iso image
my $isoname = '';
my $datadir = '';
my $burnspeed = '';
my $test = '';

GetOptions( "h|help" => \&help,       # print help
            "data=s" => \$datadir,    # set dir with data to burn
            "name=s" => \$isoname,    # set name of iso file
            "speed=s" => \$burnspeed, # set burn speed
            "t|test" => \$test,       # run test burn
            "burner=s" => \$burner ); # define burner other than default /dev/cdrw

sub help {
    say "Burner is a program that will make Your burning cd's easier under the CLI environment 
        \nWARNING: To burn Your CD You must put Your files into default /tmp/burner directory or run burner with --data=/your/burndata/directory option
        \nOPTIONS:
        -h|--help   - print this message
        -t|--test   - run in test burn mode
        --data=s   - set directory with data to burn (default /tmp/burner)
        --name=s   - set name of iso file (default cd.iso), You iso file will be stored in /tmp
        --burner=s - set burner to use (default /dev/cdrw)";
    exit 0;
} 

sub makeiso {
    my ($name, $dir) = @_;
    
    if ($dir) {
        $datadir = $dir;
    } else {
        $datadir = '/tmp/burner';
    };

    if ($name) {
        $isoname = "/tmp/$name";
    } else {
        $isoname = '/tmp/cd.iso';
    };

#    say $datadir; say $isoname; # print to test if function works good

    system("$isomaker $isomakeropts $isoname $datadir") // die "I can't burn Your cd! \n$!";
}

sub burniso {
    my ($opts);
    
    $burnisoopts = "$burnisoopts --dummy" if ($test); # run test burn if --t|test was set

    if ($burnspeed) {
        $opts = "$burnisoopts --speed=$burnspeed";
    } else {
        $opts = $burnisoopts;
    }
#    say $opts; # Test print to check is function working fine
    system( "$writer $opts $isoname" ) // die "I can't write this image! \n$!";
}

if ($isoname) {
$isoname = "$isoname.iso" if ($isoname !~ m/.iso$/); # check if file (.iso) extension is defined 
                                                     # in name, if not it'll add it
}

makeiso( $isoname, $datadir );
burniso();
