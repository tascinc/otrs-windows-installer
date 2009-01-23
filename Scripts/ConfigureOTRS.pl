#!/usr/bin/perl -w
# --
# ConfigureOTRS.pl - script to configure OTRS
# Copyright (C) 2001-2009 OTRS AG, http://otrs.org/
# --
# $Id: ConfigureOTRS.pl,v 1.6 2009-01-23 13:59:20 mh Exp $
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
use File::Copy;
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
    print STDOUT "ConfigureOTRS.pl <Revision $VERSION> - script to configure OTRS\n";
    print STDOUT "Copyright (C) 2001-2008 OTRS AG, http://otrs.org/\n";
    print STDOUT "usage: ConfigureOTRS.pl -d <install directory>\n\n";
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

# quoate the install directory
my $InstallDirQuoated = $InstallDir;
$InstallDirQuoated =~ s{\\}{/}xmsg;

# quoate the OTRS directory
my $OTRSDirQuoated = $OTRSDir;
$OTRSDirQuoated =~ s{\\}{/}xmsg;

# create Config.pm file
CreateConfigPm();

# create GenericAgent.pm file
CreateGenericAgentPm();

# set shebangline with the correct perl directory in all .pl files
find( \&ReplaceShebangLine, ($OTRSDir) );

# set directory to OTRS in the config files
ReplaceOTRSDir();

# set required parameters in Config.pm
PrepareConfigPm();

# config the Cron4Win32.pl
ConfigCron4Win32Pl();

1;

sub CreateConfigPm {

    my $SourceFile      = $OTRSDirQuoated . '/Kernel/Config.pm.dist';
    my $DestinationFile = $OTRSDirQuoated . '/Kernel/Config.pm';

    # check if source file exists
    return if !-e $SourceFile;

    # check if source file is a directory
    return if -d $SourceFile;

    copy( $SourceFile, $DestinationFile );

    return 1;
}

sub CreateGenericAgentPm {

    my $SourceFile      = $OTRSDirQuoated . '/Kernel/Config/GenericAgent.pm.dist';
    my $DestinationFile = $OTRSDirQuoated . '/Kernel/Config/GenericAgent.pm';

    # check if source file exists
    return if !-e $SourceFile;

    # check if source file is a directory
    return if -d $SourceFile;

    copy( $SourceFile, $DestinationFile );

    return 1;
}

sub ReplaceShebangLine {

    # get filename

    my $File = $File::Find::name;

    # return if file is not a .pl file
    return if $File !~ m{ .+ \.pl \z }xms;

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

    # create path to perl
    my $PerlQuoated = $InstallDirQuoated . '/StrawberryPerl/perl/bin/perl.exe';

    # find and replace all #!/usr/bin/perl
    $NewString =~ s{ ^ \#\!\/usr\/bin\/perl }{#!$PerlQuoated}xms;

    # next file if no changes
    return 1 if $OrgString eq $NewString;

    # write new file
    return if !open my $FH2, '>', $File;
    print $FH2 $NewString;
    close $FH2;

    print STDERR "Replaced string #!/usr/bin/perl in $File\n";

    return 1;
}

sub ReplaceOTRSDir {

    FILE:
    for my $FileName (
        qw(Kernel/Config.pm scripts/apache2-httpd-new.include.conf scripts/apache2-perl-startup.pl)
        )
    {

        # add directory to otrs
        my $File = $OTRSDirQuoated . '/' . $FileName;

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
        $NewString =~ s{ \/opt\/otrs }{$OTRSDirQuoated}xmsg;

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

    my $File = $OTRSDirQuoated . '/Kernel/Config.pm';

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
    \$Self->{LogModule}          = 'Kernel::System::Log::File';
    \$Self->{LogModule::LogFile} = '$OTRSDirQuoated/var/log/otrs.log';
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

    my $File = $InstallDirQuoated . '/OTRS/bin/Cron4Win32.pl';

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
        =~ s{(my \$PerlExe   = ")(";)}{$1$InstallDirQuoated/StrawberryPerl/perl/bin/perl.exe$2};
    $NewString =~ s{(my \$Directory = ")(";)}{$1$OTRSDirQuoated/var/cron/$2};
    $NewString =~ s{(my \$CronTab   = ")(";)}{$1$InstallDirQuoated/CRONw/crontab.txt$2};
    $NewString =~ s{(my \$OTRSHome  = ")(";)}{$1$OTRSDirQuoated$2};

    # return if no changes
    return 1 if $OrgString eq $NewString;

    # write new file
    return if !open my $FH2, '>', $File;
    print $FH2 $NewString;
    close $FH2;

    return 1;
}

exit 0;
