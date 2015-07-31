#!/usr/local/bin/perl

use strict;
use warnings;
use File::Find;
use File::Basename;

#my $dir = '/proj/xhd_edk_tools/users/somdutt/Dev/zynq_dev/env/Jobs/igen/ZynqConfig/data';
my $dir = '/build/xfndry/HEAD/env/Jobs/igen/ZynqConfig/data';

find(\&Wanted, $dir);

sub Wanted
{
 #       print "$_\r";
        my $file = $_;
        if (-d $file ) {
            return;
        }
        my $pwd = $File::Find::dir;
        $pwd = basename($pwd);
        if ($file =~ m/\.xml/) {
        print "$file\n";
        print "$pwd\n";
        my $vivdir = join ("/", "/proj/xhd_edk_tools/users/somdutt/Dev/zynq_dev/env/Jobs/igen/ZynqConfig/viv_data" , "$pwd");
        mkdir $vivdir;
        print "VIV : $vivdir\n";

        my $out = join ("/", "$vivdir" , "$file");
#        my $out = "/proj/xhd_edk_tools/users/somdutt/Dev/zynq_dev/env/Jobs/igen/ZynqConfig/viv_data/$file";
        print "$out\n";
        open (OUTFILE, "> $out") or die "Unable to open file";
        open (MYFILE, $_);
        while (<MYFILE>) {
                chomp;
                my $string = $_;
                $string =~ s/::/_/g;
#                print "$string\n";
                print OUTFILE "$string\n";

        }
        close (MYFILE); 
        }
}

        close (OUTFILE); 
