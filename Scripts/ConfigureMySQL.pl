#!/usr/bin/perl
# --
# ConfigureMySQL.pl - script to configure MySQL
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
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
use File::Copy;
use File::Find;

# get options
my %Opts = ();
getopt( 'd', \%Opts );

# check arguments
if ( !$Opts{'d'} ) {
    $Opts{'h'} = 1;
}
if ( $Opts{'h'} ) {
    print STDOUT "ConfigureMySQL.pl <Revision - script to configure MySQL\n";
    print STDOUT "Copyright (C) 2001-2014 OTRS AG, http://otrs.com/\n";
    print STDOUT "usage: ConfigureMySQL.pl -d <install directory>\n\n";
    exit 1;
}

# check the given install directory
my $InstallDir = $Opts{'d'};
if ( !-e $InstallDir || !-d $InstallDir ) {
    print STDERR "Invalid install directory!\n\n";
    exit 1;
}

# check the MySQL directory
my $MySQLDir = $InstallDir . '\MySQL';
if ( !-e $MySQLDir || !-d $MySQLDir ) {
    print STDERR "Invalid MySQL directory!\n\n";
    exit 1;
}

# quote the install directory
my $InstallDirQuoted = $InstallDir;
$InstallDirQuoted =~ s{\\}{/}xmsg;

# quote the MySQL directory
my $MySQLDirQuoted = $MySQLDir;
$MySQLDirQuoted =~ s{\\}{/}xmsg;

# create my.ini
CreateMyIni();

# set required parameters in my.ini
PrepareMyIni();

1;

sub CreateMyIni {

    my $SourceFile      = $MySQLDirQuoted . '/my-medium.ini';
    my $DestinationFile = $MySQLDirQuoted . '/my.ini';

    # check if source file exists
    return if !-e $SourceFile;

    # check if source file is a directory
    return if -d $SourceFile;

    copy( $SourceFile, $DestinationFile );

    return 1;
}

sub PrepareMyIni {

    my $File = $MySQLDirQuoted . '/my.ini';

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
    ## no critic
    return if !open my $FH1, '<', $File;
    ## use critic
    my $OrgString = do { local $/; <$FH1> };
    close $FH1;

    # copy the string
    my $NewString = $OrgString;

    # insert query cache
    $NewString =~ s{ \[mysqld\] }{[mysqld]
query_cache_limit = 8M
query_cache_size = 32M
query_cache_type = 1}xms;

    # insert basedir
    $NewString =~ s{ \[mysqld\] }{[mysqld]\nbasedir = $MySQLDirQuoted}xms;

    # increase max_allowed_packet
    $NewString =~ s{ max_allowed_packet \s* = \s* \d M }{max_allowed_packet = 20M}xmsg;

    # return if no changes
    return 1 if $OrgString eq $NewString;

    # write new file
    ## no critic
    return if !open my $FH2, '>', $File;
    ## use critic
    print $FH2 $NewString;
    close $FH2;

    return 1;
}

exit 0;
