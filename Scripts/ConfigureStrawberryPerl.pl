#!/usr/bin/perl -w
# --
# ConfigureStrawberryPerl.pl - script to configure StrawberryPerl
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# $Id: ConfigureStrawberryPerl.pl,v 1.7 2012-11-20 19:18:31 mh Exp $
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
use File::Find;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.7 $) [1];

# get options
my %Opts = ();
getopt( 'd', \%Opts );

# check arguments
if ( !$Opts{'d'} ) {
    $Opts{'h'} = 1;
}
if ( $Opts{'h'} ) {
    print STDOUT
        "ConfigureStrawberryPerl.pl <Revision $VERSION> - script to configure StrawberryPerl\n";
    print STDOUT "Copyright (C) 2001-2012 OTRS AG, http://otrs.org/\n";
    print STDOUT "usage: ConfigureStrawberryPerl.pl -d <install directory>\n\n";
    exit 1;
}

# check the given install directory
my $InstallDir = $Opts{'d'};
if ( !-e $InstallDir || !-d $InstallDir ) {
    print STDERR "Invalid install directory!\n\n";
    exit 1;
}

# check the StrawberryPerl directory
my $StrawberryPerlDir = $InstallDir . '\StrawberryPerl';
if ( !-e $StrawberryPerlDir || !-d $StrawberryPerlDir ) {
    print STDERR "Invalid StrawberryPerl directory!\n\n";
    exit 1;
}

# quote the install directory
my $InstallDirQuoted = $InstallDir;
$InstallDirQuoted =~ s{\\}{/}xmsg;

# quote the StrawberryPerl directory
my $StrawberryPerlDirQuoted = $StrawberryPerlDir;
$StrawberryPerlDirQuoted =~ s{\\}{/}xmsg;

my $OTRSDir = $InstallDir . '\OTRS';
if ( !-e $OTRSDir || !-d $OTRSDir ) {
    print STDERR "Invalid OTRS directory!\n\n";
    exit 1;
}

# quote the OTRS directory
my $OTRSDirQuoted = $OTRSDir;
$OTRSDirQuoted =~ s{\\}{/}xmsg;
1;

exit 0;
