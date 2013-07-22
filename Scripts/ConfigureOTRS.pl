#!/usr/bin/perl
# --
# ConfigureOTRS.pl - script to configure OTRS
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
use File::Copy;
use File::Find;
use Win32;

# get options
my %Opts = ();
getopts( 'sd:', \%Opts );

# check arguments
if ( !$Opts{'d'} ) {
    $Opts{'h'} = 1;
}
if ( $Opts{'h'} ) {
    print "ConfigureOTRS.pl - script to configure OTRS\n";
    print "Copyright (C) 2001-2013 OTRS AG, http://otrs.com/\n";
    print "usage: ConfigureOTRS.pl -d <install directory> -s\n\n";
    print " -s will update shebang line in cgi-bin scripts\n\n";
    exit 1;
}

# check the given install directory
my $InstallDir = $Opts{'d'};
if ( !-e $InstallDir || !-d $InstallDir ) {
    print STDERR "Invalid install directory!\n\n";
    exit 1;
}

# check the OTRS directory
my $OTRSDir = $InstallDir . '\OTRS';
if ( !-e $OTRSDir || !-d $OTRSDir ) {
    print STDERR "Invalid OTRS directory!\n\n";
    exit 1;
}

# quote the install directory
my $InstallDirQuoted = $InstallDir;
$InstallDirQuoted =~ s{\\}{/}xmsg;

# quote the OTRS directory
my $OTRSDirQuoted = $OTRSDir;
$OTRSDirQuoted =~ s{\\}{/}xmsg;

# create Config.pm file
CreateConfigPm();

# create GenericAgent.pm file
CreateGenericAgentPm();

# set directory to OTRS in the config files
ReplaceOTRSDir();

# set required parameters in Config.pm
PrepareConfigPm();

# config the Cron4Win32.pl
ConfigCron4Win32Pl();

if ( $Opts{s} ) {
    # modify shebang line of files in cgi-bin
    my $CGIBin = File::Spec->catdir( $InstallDir, 'OTRS\bin\cgi-bin' );
    find ( \&UpdateShebang, ($CGIBin) );
}

1;

sub CreateConfigPm {

    my $SourceFile      = $OTRSDirQuoted . '/Kernel/Config.pm.dist';
    my $DestinationFile = $OTRSDirQuoted . '/Kernel/Config.pm';

    # check if source file exists
    return if !-e $SourceFile;

    # return if target file exists (for instance, when upgrading!)
    return if -e $DestinationFile;

    copy( $SourceFile, $DestinationFile );

    return 1;
}

sub CreateGenericAgentPm {

    my $SourceFile      = $OTRSDirQuoted . '/Kernel/Config/GenericAgent.pm.dist';
    my $DestinationFile = $OTRSDirQuoted . '/Kernel/Config/GenericAgent.pm';

    # check if source file exists
    return if !-e $SourceFile;

    # check if source file is a directory
    return if -d $SourceFile;

    copy( $SourceFile, $DestinationFile );

    return 1;
}

sub ReplaceOTRSDir {

    FILE:
    for my $FileName (
        qw(Kernel/Config.pm scripts/apache2-httpd.include.conf scripts/apache2-perl-startup.pl)
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

        # copy the string
        my $NewString = $OrgString;

        # find and replace all /opt/otrs
        $NewString =~ s{ \/opt\/otrs }{$OTRSDirQuoted}xmsg;

        # next file if no changes
        next FILE if $OrgString eq $NewString;

        # write new file
        return if !open my $FH2, '>', $File;
        print $FH2 $NewString;
        close $FH2;

        print STDERR "Replaced string /opt/otrs in $File\n";
    }

    return 1;
}

sub PrepareConfigPm {

    my $File = $OTRSDirQuoted . '/Kernel/Config.pm';

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

    my $Configuration = "
    \$Self->{'LogModule'}          = 'Kernel::System::Log::File';
    \$Self->{'LogModule::LogFile'} = '$OTRSDirQuoted/var/log/otrs.log';
    # \$DIBI\$
";

    # insert configuration
    $NewString =~ s{ ^ \s \s \s \s \# \s \$ DIBI \$ }{$Configuration}xms;

    # return if no changes
    return 1 if $OrgString eq $NewString;

    # write new file
    return if !open my $FH2, '>', $File;
    print $FH2 $NewString;
    close $FH2;

    return 1;
}

sub ConfigCron4Win32Pl {

    my $File = $InstallDirQuoted . '/OTRS/bin/otrs.Cron4Win32.pl';

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

    # insert configuration
    $NewString
        =~ s{(my \$PerlExe\s*= ")(";)}{$1$InstallDirQuoted/StrawberryPerl/perl/bin/perl.exe$2};
    $NewString =~ s{(my \$Directory\s*= ")(";)}{$1$OTRSDirQuoted/var/cron/$2};
    $NewString =~ s{(my \$CronTab\s*= ")(";)}{$1$InstallDirQuoted/CRONw/crontab.txt$2};
    $NewString =~ s{(my \$CronTabFile\s*= ")(";)}{$1$InstallDirQuoted/CRONw/crontab.txt$2};
    $NewString =~ s{(my \$OTRSHome\s*= ")(";)}{$1$OTRSDirQuoted$2};

    # return if no changes
    return 1 if $OrgString eq $NewString;

    # write new file
    return if !open my $FH2, '>', $File;
    print $FH2 $NewString;
    close $FH2;

    return 1;
}

sub UpdateShebang {

    # get filename

    my $File = $File::Find::name;

    # next file if no .conf file
    return if $File !~ m{ .+ \.pl \z }xms;

    # check if file exists
    return if !-e $File;

    # check if file is a directory
    return if -d $File;

    # check if file is writeable
    return if !-w $File;

    # check if file is a link
    return if -l $File;

    # read file
    return if !open my $FH1, '<', $File;
    my $OrgString = do { local $/; <$FH1> };
    close $FH1;

    # copy the string
    my $NewString = $OrgString;

    my $PerlBin = Win32::GetShortPathName($^X);

    # find and replace all /usr/bin/perl occurrences
    $NewString =~ s{ /usr/bin/perl }{$PerlBin}xmsg;

    # next file if no changes
    return 1 if $OrgString eq $NewString;

    # write new file
    return if !open my $FH2, '>', $File;
    print $FH2 $NewString;
    close $FH2;

    print STDERR "Replaced shebang in $File\n";

    return 1;
}

exit 0;
