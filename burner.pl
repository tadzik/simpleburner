#!/usr/bin/env perl
# file: burner.pl - it'll make Your burning cd's easier
#  
#   Copyright 2009 Marcin Karpezo <sirmacik at gmail dot com>
#   license = GPLv3 
#   version = 
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

my $burner = '/dev/cdrw';       # Here You have to setup Your CD writer

my $writer = 'woodim';          # You could set this options to work 
my $isomaker = 'genisoimage';   # with cdrtools instead of cdrkit

my $isomakeropts = '-U -o';     # Options used to make iso image
my $isoname = '';
my $datadir = '';

GetOptions( "h|help" => \&help,      # print help
            "data=s" => \$datadir,   # set dir with data to burn
            "name=s" => \$isoname ); # set name of iso file

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

    say $datadir; say $isoname; # print to test if function works good

    system("$isomaker $isomakeropts $isoname $datadir") // die "I can't burn Your cd! \n$!";
}

$isoname if ($isoname =~ m/.iso$/) or $isoname = "$isoname.iso"; # check if file (.iso) extension is deined 
                                                                 # in name, if not it'll add it

makeiso( $isoname, $datadir );
