#!/usr/bin/perl -w
# --
# ConfigureStrawberryPerl.pl - script to configure StrawberryPerl
# Copyright (C) 2001-2009 OTRS AG, http://otrs.org/
# --
# $Id: ConfigureStrawberryPerl.pl,v 1.3 2009-09-04 12:19:24 mb Exp $
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
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;

use Getopt::Std;
use File::Find;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.3 $) [1];

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
    print STDOUT "Copyright (C) 2001-2009 OTRS AG, http://otrs.org/\n";
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

# quoate the install directory
my $InstallDirQuoted = $InstallDir;
$InstallDirQuoted =~ s{\\}{/}xmsg;

# quoate the StrawberryPerl directory
my $StrawberryPerlDirQuoted = $StrawberryPerlDir;
$StrawberryPerlDirQuoted =~ s{\\}{/}xmsg;

1;

exit 0;
