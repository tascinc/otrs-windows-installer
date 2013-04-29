#!/usr/bin/perl
# --
# GetOTRSArchive.pl - script to get zipballs and configure OTRS.nsi
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

use Archive::Extract;
use Cwd;
use File::Basename;
use File::Path qw(remove_tree);
use File::Spec;
use File::Temp qw(tempfile);
use LWP::Simple;

my $URL = shift @ARGV || die "Usage: $0 [url] i.e. $0 http://example.com/otrs-3.x.x.zip\n";

die "URL $URL does not end in .zip!\n" if $URL !~ /\.zip$/;

# checking if NSIS file is in place
my $Path = getcwd;
my $NSISFile = File::Spec->catfile( $Path, 'otrs4win\OTRS.nsi' );
if ( !-e $NSISFile ) {
    die "Can't find NSIS installer file $NSISFile!\n";
}

# remove current OTRS directory if exists
my $OTRSDir = File::Spec->catfile( $Path, 'OTRS' );
if ( -d $OTRSDir ) {
    print "Removing old OTRS directory $OTRSDir...\n";
    remove_tree($OTRSDir);
    print "Done.\n\n";
}

# download zip archive
print "Downloading from $URL...\n";
my ( $FileHandle, $FileName ) = tempfile( TEMPLATE => 'otrsXXXXXXXXX', SUFFIX => '.zip' );
my $ResponseCode = getstore( $URL, $FileName );
die "Problem from downloading '$URL', response code $ResponseCode!\n" if $ResponseCode ne '200';
close $FileHandle;
print "Done.\n\n";

# extract archive
print "Extracting zip archive...\n";
my $Archive = Archive::Extract->new( archive => $FileName );
die "Not a .zip archive!\n" if !$Archive->is_zip();
$Archive->extract() || die $Archive->error();
print "Done.\n\n";

# move in place
my $ExtractedDirectory = File::Spec->catfile( $Path, basename( $URL, '.zip' ) );
print "Renaming directory...\n";
die if !-d $ExtractedDirectory;
rename $ExtractedDirectory, File::Spec->catfile( $Path, 'OTRS' );
print "Done.\n\n";

# update nsis installer file with current version
print "Updating NSIS installer file...\n";
my $Product = basename( $URL, '.zip' );
my %V;
( $V{Major}, $V{Minor}, $V{Patch}, $V{Jointer}, $V{Postfix} )
    = ( $Product =~ /-(\d*)\.(\d*)\.(\d*)\.?(beta|rc|)(\d*)/ );

# read in nsi file
open my $NSISInFile, '<', $NSISFile || die "Can't open $NSISFile: $@";    ## no critic
my $OrgString = do { local $/; <$NSISInFile> };
close $NSISInFile;

# replace values
for my $Value ( keys %V ) {
    $OrgString =~ s{define OTRS_Version_$Value (.*)}{define OTRS_Version_$Value "$V{$Value}"};
}

# write out changes
open my $NSISOutfile, '>', $NSISFile || die "Can't open $NSISFile: $@";    ## no critic
print $NSISOutfile $OrgString;
close $NSISOutfile;
print "Done.\n\n";
