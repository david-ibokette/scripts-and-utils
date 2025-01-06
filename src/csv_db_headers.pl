#!/usr/bin/perl -w
use feature ":5.10";
use warnings FATAL => 'all';
use strict;
use POSIX qw(strftime);
use Getopt::Long;

# csv_db_headers --infile ~/bsi_all_20241213.csv --outfile ~/bsi_20241219-01.csv --force

my $timestampString = strftime("%Y%m%dT%H%M%S", localtime(time()));

sub fixHeader {
	chomp(my $line = shift(@_));
	$line =~ s/[&\/# ]/_/g;
	$line = lc($line);
	$line =~ s/_{2,}/_/g;
	$line =~ s/_+$//g;
	return $line;
}

(my $exeName = $0) =~ s/^(?:.+\/)([^\/]+?)(?:.pl)?$/$1/;
my $USAGE = "usage: $exeName --infile <file> --outfile <outfile> [--force]";

my $force = 0;
my $infile;
my $outfile;
GetOptions(
    "infile=s" => \$infile,
    "outfile=s" => \$outfile,
    "force" => \$force
) or die $USAGE;

if (!$infile) { die "Need a filename" }
if (!$outfile) { die "Need an output filename" }

if (! -r $infile) {
	die "$infile must be readable";
}

$outfile =~ s/%ts%/$timestampString/g;
if (!$force && -f $outfile) {
	die "$outfile already exists - cannot write to it";
}

open(FH, $infile) or die "File '$infile' can't be opened";
open(OFH, ">$outfile") or die "File '$outfile' can't be opened";

my $lineNumber = -1;
while (<FH>) {
	++$lineNumber;

	if ($lineNumber == 0) {
		my $line = fixHeader($_);
		say OFH $line;
	} else {
		print OFH $_;
	}
}
say "Done - outfile is $outfile";
