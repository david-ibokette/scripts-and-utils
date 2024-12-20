#!/usr/bin/perl -w
use feature ":5.10";
use warnings FATAL => 'all';
use POSIX qw(strftime);
use Email::Address;
use Getopt::Long;

# for Email::Address, need to from CLI: perl -MCPAN -e shell
# and then in the tool: install Email::Address
# once done, 'exit'

# gen_rand_emails --infile ~/bsi_all_20241213.csv --outfile ~/bsi_20241219-01.csv --lines 2001-3000 --force

my $timestampString = strftime("%Y%m%dT%H%M%S", localtime(time()));
my $lineProcessedCount = 0;
my $tagLength = 4;
my $emailPrefix = "pextest_";
my $emailDomain = "example.net";

sub getNewLine {
	chomp(my $line = shift(@_));
	my @addrs = Email::Address->parse($line);
	foreach my $email (@addrs) {
		my $rowIdentifier = "";
		$rowIdentifier .= sprintf("%s_%0${tagLength}d", $timestampString, ++$lineProcessedCount);
		$line =~ s/$email/${emailPrefix}${rowIdentifier}\@${emailDomain}/g;
	}
	return $line;
}

(my $exeName = $0) =~ s/^(?:.+\/)([^\/]+)$/$1/;
my $USAGE = "usage: $exeName --infile <file> --outfile <outfile> --lines <lines> [--force]";

my $force = 0;
GetOptions(
    "infile=s" => \$infile,
    "outfile=s" => \$outfile,
    "lines=s" => \$lineString,
	"prefix=s" => \$emailPrefix,
	"domain=s" => \$emailDomain,
    "force" => \$force
) or die $USAGE;

if (!$infile) { die "Need a filename" }
if (!$outfile) { die "Need an output filename" }
if (!$lineString) { die "Need a lines argument" }

if (! -r $infile) {
	die "$infile must be readable";
}

$outfile =~ s/%ts%/$timestampString/g;
if (!$force && -f $outfile) {
	die "$outfile already exists - cannot write to it";
}

my $startLine = 0;
my $endLine = 0;

if ($lineString =~ m/^(\d+)-(\d+)$/) {
	$startLine = $1;
	$endLine = $2;
	$tagLength = length($endLine);
}

if ($startLine <= 0 || $endLine <= 0) {
	die "Invalid lines argument";
}

open(FH, $infile) or die "File '$infile' can't be opened";
open(OFH, ">$outfile") or die "File '$outfile' can't be opened";

my $lineNumber = -1;
while (<FH>) {
	++$lineNumber;

	if ($lineNumber == 0 || ($lineNumber >= $startLine && $lineNumber <= $endLine)) {
		$line = getNewLine($_);
		say OFH $line;
	}
}
say "Done - outfile is $outfile";
