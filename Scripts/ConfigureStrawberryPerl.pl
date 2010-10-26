#!/usr/bin/perl -w
# --
# ConfigureStrawberryPerl.pl - script to configure StrawberryPerl
# Copyright (C) 2001-2010 OTRS AG, http://otrs.org/
# --
# $Id: ConfigureStrawberryPerl.pl,v 1.5 2010-10-26 11:49:31 mb Exp $
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
$VERSION = qw($Revision: 1.5 $) [1];

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
    print STDOUT "Copyright (C) 2001-2010 OTRS AG, http://otrs.org/\n";
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

AddPerlPath();

1;

sub AddPerlPath {

    FILE:
    for my $FileName (
        qw(scripts/apache2-perl-startup.pl)
        )
    {

        # add directory to otrs
        my $File = $OTRSDirQuoted . '/' . $FileName;

        # check if file exists
        next FILE if !-e $File;

        # check if file is a directory
        next FILE if -d $File;

        # check if file is writeable
        next FILE if !-w $File;

        # check if file is a link
        next FILE if -l $File;

        # check if file is a text file
        next FILE if !-T $File;

        # read file
        next FILE if !open my $FH1, '<', $File;
        my $OrgString = do { local $/; <$FH1> };
        close $FH1;
        print "read in $File\n";

        # copy the string
        my $NewString = $OrgString;

        # prepare Strawberry Path string
        $StrawberryPerlDirQuoted =~ s{/}{\\}xmsg;
        my $PerlPath
            = "\$ENV{PATH} .= ';$StrawberryPerlDirQuoted\\site\\bin;$StrawberryPerlDirQuoted\\perl\\bin;$StrawberryPerlDirQuoted\\c\\bin';";

        # find and replace path placeholder to Perl path
        $NewString =~ s/# add perl path here if needed/$PerlPath/;

        # next file if no changes
        next FILE if $OrgString eq $NewString;

        # write new file
        return if !open my $FH2, '>', $File;
        print $FH2 $NewString;
        close $FH2;

        print STDERR "Added Perl paths to $File\n";
    }

    return 1;
}

exit 0;
