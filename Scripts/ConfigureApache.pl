#!/usr/bin/perl -w
# --
# ConfigureApache.pl - script to configure the apache server
# Copyright (C) 2001-2008 OTRS AG, http://otrs.org/
# --
# $Id: ConfigureApache.pl,v 1.2 2008-11-27 14:17:11 mh Exp $
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# --

use strict;
use warnings;

use Getopt::Std;
use File::Find;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.2 $) [1];

# get options
my %Opts = ();
getopt( 'd', \%Opts );

# check arguments
if ( !$Opts{'d'} ) {
    $Opts{'h'} = 1;
}
if ( $Opts{'h'} ) {
    print STDOUT "ConfigureApache.pl <Revision $VERSION> - script to configure the apache\n";
    print STDOUT "Copyright (C) 2001-2008 OTRS AG, http://otrs.org/\n";
    print STDOUT "usage: ConfigureApache.pl -d <install directory>\n\n";
    exit 1;
}

# check the given install directory
my $InstallDir = $Opts{'d'};
if ( !-e $InstallDir || !-d $InstallDir ) {
    print STDERR "Invalid install directory!\n\n";
    exit 1;
}

# check the apache directory
my $ApacheDir = $InstallDir . '\Apache';
if ( !-e $ApacheDir || !-d $ApacheDir ) {
    print STDERR "Invalid apache directory!\n\n";
    exit 1;
}

# quoate the install directory
my $InstallDirQuoated = $InstallDir;
$InstallDirQuoated =~ s{\\}{/}xmsg;

# quoate the apache directory
my $ApacheDirQuoated = $ApacheDir;
$ApacheDirQuoated =~ s{\\}{/}xmsg;

# replace C:/Apache with the install directory in all config files
find( \&ReplaceApacheDir, ($ApacheDir) );

# add OTRS configuration to the http.conf
OTRSApacheConfigAdd();

# config the OTRS server start and restart scripts
ConfigOTRSServiceStart();

# config the OTRS server stop and restart scripts
ConfigOTRSServiceStop();

1;

sub ReplaceApacheDir {

    # get filename

    my $File = $File::Find::name;

    # next file if no .conf file
    return if $File !~ m{ .+ \.conf \z }xms;

    # check if file exists
    return if !-e $File;

    # check if file is a directory
    return if -d $File;

    # check if file is writeable
    return if !-w $File;

    # check if file is a link
    return if -l $File;

    # check if file is a text file
    return if !-T $File;

    # read file
    return if !open my $FH1, '<', $File;
    my $OrgString = do { local $/; <$FH1> };
    close $FH1;

    # copy the string
    my $NewString = $OrgString;

    # find and replace all C:/Apache
    $NewString =~ s{ C:\/Apache }{$ApacheDirQuoated}xmsg;

    # next file if no changes
    return 1 if $OrgString eq $NewString;

    # write new file
    return if !open my $FH2, '>', $File;
    print $FH2 $NewString;
    close $FH2;

    print STDERR "Replaced string C:/Apache in $File\n";

    return 1;
}

sub OTRSApacheConfigAdd {

    my $HttpdConf = $ApacheDir . '/conf/httpd.conf';

    # check if http.con exists
    return if !-e $HttpdConf;

    # check if file is writeable
    return if !-w $HttpdConf;

    my $OTRSConfig = "
# ---
# OTRS configuration
# ---

# load mod_perl
#LoadFile '$InstallDirQuoated/StrawberryPerl/perl/bin/perl510.dll'
#LoadModule perl_module modules/mod_perl.so

# include the OTRS configuration
Include '$InstallDirQuoated/OTRS/scripts/apache2-httpd-new.include.conf'

# ---
";

    # add config to the httpd.conf
    return if !open my $FH, '>>', $HttpdConf;
    print $FH $OTRSConfig;
    close $FH;

    return 1;
}

sub ConfigOTRSServiceStart {

    FILE:
    for my $FileName (qw(OTRSServicesStart.bat OTRSServicesRestart.bat)) {

        # add install directory
        my $File = $InstallDirQuoated . '/otrs4win/Scripts/' . $FileName;

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

        my $StartConfig = "REM Start Apache service
\"$ApacheDir\\bin\\httpd.exe\" -k start";

        # add the apache start part
        $NewString =~ s{ ^ REM \s ---ApacheStartPart--- }{$StartConfig}xmsg;

        # next file if no changes
        next FILE if $OrgString eq $NewString;

        # write new file
        return if !open my $FH2, '>', $File;
        print $FH2 $NewString;
        close $FH2;

        print STDERR "Replaced string 'REM ---ApacheStartPart---' in $File\n";
    }
}

sub ConfigOTRSServiceStop {

    FILE:
    for my $FileName (qw(OTRSServicesStop.bat OTRSServicesRestart.bat)) {

        # add install directory
        my $File = $InstallDirQuoated . '/otrs4win/Scripts/' . $FileName;

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

        my $StopConfig = "REM Stop Apache service
\"$ApacheDir\\bin\\httpd.exe\" -k stop";

        # add the apache stop part
        $NewString =~ s{ ^ REM \s ---ApacheStopPart--- }{$StopConfig}xmsg;

        # next file if no changes
        next FILE if $OrgString eq $NewString;

        # write new file
        return if !open my $FH2, '>', $File;
        print $FH2 $NewString;
        close $FH2;

        print STDERR "Replaced string 'REM ---ApacheStopPart---' in $File\n";
    }
}

exit 0;
