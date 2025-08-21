#!/usr/bin/perl
use strict;
use feature ":5.10";
use warnings FATAL => 'all';
use DateTime;

use Getopt::Long;

sub doAvpIfNeeded {
    my $awsExp = $ENV{AWS_SESSION_EXPIRATION};

    if (!defined $awsExp) {
        doAVP();
        return;
    }

    chomp(my $now = qx/date -u +"%Y-%m-%dT%H:%M:%SZ"/);
    if ($now gt $awsExp) {
        doAVP();
        return;
    }
}

sub doAVP {
    if (0 == 1) {
        # Keep here until I can figure out how to get AVP running from within
        say "Need to run AVP!!!";
        exit 1;
    }
    $ENV{AWS_VAULT} = undef;
    chomp(my @vars = qx/aws-vault export --format=export-env prod/);
    foreach my $var (@vars) {
        if ($var =~ /^([^=]+)=(.*)$/) {
            $ENV{$1} = $2;
        }
    }
    $ENV{AWS_VAULT}="prod";
    $ENV{AWS_SESSION_EXPIRATION} = $ENV{AWS_CREDENTIAL_EXPIRATION};
}

sub getRunningPods {
    my $env = shift(@_);
    my $grepArgs = shift(@_);

    my $envArgs = $env ? " -n $env " : "";
    my $grepCmdWithPipe = $grepArgs ? qq/ | grep "$grepArgs" / : "";
    my $cmd = "kubectl get pods $envArgs | cut -d ' ' -f 1 $grepCmdWithPipe";

    chomp(my @kpods = `$cmd`);
    $? != 0 and die "Could not run kubectl - need to run avp? bad grep?";

    return @kpods;
}

sub getPod {
    my @podList = getRunningPods(@_);

    my $index = 0;
    foreach my $pod (@podList) {
        my $pos = ++$index;
        say "${pos}) $pod";
    }

    print "which number? ";
    my $input = <STDIN>;

    if ($input !~ /^\d+$/) {
        die "Didn't get a number";
    }

    if ($input < 1 || $input > $index){
        die "invalid number";
    }

    return "$podList[$input -1]";
}

#####################################################
# Main Script
#####################################################

my $env;
my $grepArgs;
(my $exeName = $0) =~ s/^(?:.+\/)([^\/]+)$/$1/;
my $USAGE = "usage: $exeName --file <file> | $exeName --[ps|ls] | $exeName --killall";
GetOptions(
    "n=s" => \$env,
    "g=s" => \$grepArgs,
) or die $USAGE;

if (!$grepArgs && @ARGV > 0) {
    $grepArgs = shift(@ARGV);
}

# doAvpIfNeeded();
my $pod = getPod($env, $grepArgs);

say "vvvvvvvvvvvv Describe POD for vvvvvvvvvvvvvvvv";
say $pod;
say "^^^^^^^^^^^^ Describe POD for ^^^^^^^^^^^^^^^^";

sleep(1);

system "kubectl describe pod $pod";
