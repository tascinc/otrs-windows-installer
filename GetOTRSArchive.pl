#!/usr/bin/perl

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
my $NSISFile = File::Spec->catfile($Path, 'otrs4win\OTRS.nsi');
if ( !-e $NSISFile ) {
    die "Can't find NSIS installer file $NSISFile!\n";
}

# remove current OTRS directory if exists
my $OTRSDir = File::Spec->catfile($Path, 'OTRS');
if ( -d $OTRSDir ) {
    print "Removing old OTRS directory $OTRSDir...\n";
	remove_tree($OTRSDir);
	print "Done.\n\n";
}

# download zip archive
print "Downloading from $URL...\n";
my ($fh, $filename) = tempfile( TEMPLATE => 'otrsXXXXXXXXX', SUFFIX => '.zip' );
my $ResponseCode = getstore($URL, $filename);
die "Problem from downloading '$URL', response code $ResponseCode!\n"  if $ResponseCode ne '200';
close $fh;
print "Done.\n\n";

# extract archive
print "Extracting zip archive...\n";
my $ae = Archive::Extract->new( archive => $filename );
die "Not a .zip archive!\n" if !$ae->is_zip;
$ae->extract or die $ae->error;
print "Done.\n\n";

# move in place
my $ExtractedDirectory = File::Spec->catfile($Path, basename($URL, '.zip'));
print "Renaming directory...\n";
die if !-d $ExtractedDirectory;
rename $ExtractedDirectory, File::Spec->catfile($Path, 'OTRS');
print "Done.\n\n";

# update nsis installer file with current version
print "Updating NSIS installer file...\n";
my $Product =  basename($URL, '.zip');
my %V;
($V{Major}, $V{Minor}, $V{Patch}, $V{Jointer}, $V{Postfix} ) = ( $Product =~ /-(\d*)\.(\d*)\.(\d*)\.?(beta|rc|)(\d*)/);

# read in nsi file
open my $NSISInFile, '<', $NSISFile or die "Can't open $NSISFile: $@";
my $OrgString = do { local $/; <$NSISInFile> };
close $NSISInFile;

# replace values
for my $Value ( keys %V ) {
    $OrgString =~ s{define OTRS_Version_$Value (.*)}{define OTRS_Version_$Value "$V{$Value}"};
}

# write out changes
open my $NSISOutfile, '>', $NSISFile or die "Can't open $NSISFile: $@";
print $NSISOutfile $OrgString;
close $NSISOutfile;
print "Done.\n\n";