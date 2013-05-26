#!/usr/bin/perl -w
# --
# ConfigureCRONw.pl - script to configure CRONw
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# $Id: ConfigureCRONw.pl,v 1.6 2012-11-20 19:18:25 mh Exp $
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
$VERSION = qw($Revision: 1.6 $) [1];

# get options
my %Opts = ();
getopt( 'd', \%Opts );

# check arguments
if ( !$Opts{'d'} ) {
    $Opts{'h'} = 1;
}
if ( $Opts{'h'} ) {
    print STDOUT "ConfigureCRONw.pl <Revision $VERSION> - script to configure CRONw\n";
    print STDOUT "Copyright (C) 2001-2012 OTRS AG, http://otrs.org/\n";
    print STDOUT "usage: ConfigureCRONw.pl -d <install directory>\n\n";
    exit 1;
}

# check the given install directory
my $InstallDir = $Opts{'d'};
if ( !-e $InstallDir || !-d $InstallDir ) {
    print STDERR "Invalid install directory!\n\n";
    exit 1;
}

# check the CRONw directory
my $CRONwDir = $InstallDir . '\CRONw';
if ( !-e $CRONwDir || !-d $CRONwDir ) {
    print STDERR "Invalid CRONw directory!\n\n";
    exit 1;
}

# quote the install directory
my $InstallDirQuoted = $InstallDir;
$InstallDirQuoted =~ s{\\}{/}xmsg;

# quote the CRONw directory
my $CRONwDirQuoted = $CRONwDir;
$CRONwDirQuoted =~ s{\\}{/}xmsg;

# config the OTRS server start and restart scripts
ConfigOTRSServiceStart();

# config the OTRS server stop and restart scripts
ConfigOTRSServiceStop();

1;

sub ConfigOTRSServiceStart {

    FILE:
    for my $FileName (qw(OTRSServicesStart.bat OTRSServicesRestart.bat)) {

        # add install directory
        my $File = $InstallDirQuoted . '/otrs4win/Scripts/' . $FileName;

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

        # copy the string
        my $NewString = $OrgString;

        my $StartConfig = "REM Start CRONw service
\"$InstallDir\\StrawberryPerl\\perl\\bin\\perl.exe\" \"$InstallDir\\OTRS\\bin\\otrs.Cron4Win32.pl\"
NET START CRON";

        # add the CRONw start part
        $NewString =~ s{ ^ REM \s ---CRONwStartPart--- }{$StartConfig}xmsg;

        # next file if no changes
        next FILE if $OrgString eq $NewString;

        # write new file
        return if !open my $FH2, '>', $File;
        print $FH2 $NewString;
        close $FH2;

        print STDERR "Replaced string 'REM ---CRONwStartPart---' in $File\n";
    }
}

sub ConfigOTRSServiceStop {

    FILE:
    for my $FileName (qw(OTRSServicesStop.bat OTRSServicesRestart.bat)) {

        # add install directory
        my $File = $InstallDirQuoted . '/otrs4win/Scripts/' . $FileName;

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

        # copy the string
        my $NewString = $OrgString;

        my $StopConfig = "REM Stop CRONw service
NET STOP CRON";

        # add the CRONw stop part
        $NewString =~ s{ ^ REM \s ---CRONwStopPart--- }{$StopConfig}xmsg;

        # next file if no changes
        next FILE if $OrgString eq $NewString;

        # write new file
        return if !open my $FH2, '>', $File;
        print $FH2 $NewString;
        close $FH2;

        print STDERR "Replaced string 'REM ---CRONwStopPart---' in $File\n";
    }
}

exit 0;