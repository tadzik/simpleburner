#!/usr/bin/env perl
# file: simpleburner.pl - it'll make Your burning cd's easier under the CLI environment
  
# Copyright (c) 2009, Marcin Karpezo
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
#
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

my $burner = '/dev/sr0';       # Here You have to setup Your CD writer (if other than primary drive)

my $writer = 'wodim';           # You could set this options to work 
my $isomaker = 'genisoimage';   # with cdrtools instead of cdrkit

my $isomakeropts = '-U -o';     # Options used to make iso image
my $burnisoopts = "--eject -v --dev=$burner";     # Options used to burn iso image
my $isoname = '';
my $datadir = '';
my $dirname = '';
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
    exit 0;

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
    print "$dir \n";
     
    if ($dir) {
        $dirname = $dir;
    } else {
        $dirname = '/tmp/burner/';
    };
    system("$isomaker $isomakeropts $isoname $dirname") and die "I can't burn Your cd! \n$!";
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

if ($burn) {
    burniso();
} elsif ($makeiso) {
    makeiso( $datadir );
} else {
    makeiso( $datadir );
    burniso();
}

