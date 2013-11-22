#!/usr/bin/perl
# --
# RemoveOldFrameworkFiles.pl - script to identify and remove old framework files
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;

use Getopt::Std;
use File::Spec;

my $Action = 'show';
my %Compare;
my %Types = (
    'o' => 'old',
    'n' => 'new'
);

# get options
my %Opts = ();
getopt( 'haond', \%Opts );

# help option
if ( $Opts{h} ) {
    _Help();
}

if ( defined $Opts{a} && lc $Opts{a} eq 'remove' ) {
    $Action = 'remove';
    if ( !defined $Opts{d} ) {
        print "missing -d option!\n";
        _Help();
    }
    if ( !-d $Opts{d} ) {
        print "Directory $Opts{d} does not exist!\n";
        exit 1;
    }
}

# read in file list from ARCHIVE files in hash for comparison
for my $Archive ( sort keys %Types ) {
    if ( !defined $Opts{$Archive} ) {
        print "Missing -$Archive option!\n";
        _Help();
    }
    if ( !-e $Opts{$Archive} ) {
        print "File $Opts{$Archive} does not exist!\n";
        exit 1;
    }

    ## no critic
    open( my $FH, '<', $Opts{$Archive} ) || die "ERROR: Can't open $Opts{$Archive}: $!";
    ## use critic

    while (<$FH>) {

        # we have the MD5sum and then the file name, we want the last part
        my @Row = split( /::/, $_ );
        my $Filename = $Row[1];
        chomp $Filename;

        # add to hash
        $Compare{$Archive}{$Filename} = 1;
    }
    close $FH;
}

# comparison
FILE:
for my $File ( sort keys %{ $Compare{o} } ) {

    next FILE if exists $Compare{n}{$File};

    if ( $Action eq 'remove' ) {

        my $FilePath = File::Spec->catfile( $Opts{d}, $File );

        if ( !-e $FilePath ) {
            print "File $FilePath does not exist on disk!\n";
            next FILE;
        }
        unlink $FilePath;
    }
    print "$File\n";
}

exit;

# Internal
sub _Help {
    print STDOUT
        "RemoveOldFrameworkFiles.pl <Revision - script to identify and remove old framework files\n";
    print STDOUT "Copyright (C) 2001-2013 OTRS AG, http://otrs.com/\n";
    print STDOUT "usage: $0 -a [show|remove] -o OldARCHIVE -n ARCHIVE [ -d <install directory>]\n";
    print STDOUT " ( -d is required for remove action )\n\n";
    exit 1;
}
