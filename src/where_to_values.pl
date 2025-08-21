#!/usr/bin/perl -w
use strict;
use feature ":5.10";
use warnings FATAL => 'all';

# Usage: cat a.txt | where_to_values.pl
#
# Where the contents of a.txt is the line below (obtained from DataGrip's "Where clause" extractor). The output of the script will be the
# SELECT clause beneath. Note: maybe should create a custom extractor in DataGrip - that could be useful.

#
#     name IN ('Dairy Land', 'State Farm Insurance Company', 'USAA', 'Ahoy!', 'Superior Flood', 'GAINSCO', 'AIG Exchange Private Client', 'Evolve', 'Employers Insurance Group', 'Highland Insurance Solutions', 'RTSpeciality', 'Great American Insurance', 'Victor Insurance', 'Pacific Speciality', 'Liberty Mutual Insurance Co', 'American Family Insurance', 'American Modern Insurance Co', 'Auto Owners Insurance', 'Erie Insurance Group', 'SWBC Insurance Line Setup', 'NEXT', 'Chubb')
#

# SELECT column1
#FROM (VALUES 
#    ('352827533'),
#    ('352718792'),
#    ('344737704'),
#    ('344737503'),
#    ('355516724'),
#    ('344745311'),
#    ('349581841'),
#    ('344745167'),
#    ('344745360'),
#    ('349580883'),
#    ('344745944'),
#    ('344745050'),
#    ('349581732'),
#    ('344744998'),
#    ('355515053'),
#    ('344741902'),
#    ('349583145'),
#    ('344740083'),
#    ('355514323'),
#    ('356172466'),
#    ('344738972'),
#    ('349581735'),
#    ('344738338'),
#    ('355514611'),
#    ('355948346')
#) AS t(column1)
while (<STDIN>) {
	chomp(my $line = $_);
	$line =~ s/^[^(]*\(//;
	$line =~ s/\)\s*$//;
	$line =~ s/', *'/'),\n('/g;
	$line = "(" . $line . ")";
	say "SELECT column1\nFROM(VALUES\n$line\n) AS t(column1)";
}
