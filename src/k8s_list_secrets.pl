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
    if (1 == 1) {
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

sub getSecrets {
    my $grepArgs = shift(@_);

    my $grepCmdWithPipe = $grepArgs ? qq/ | grep "$grepArgs" / : "";
    my $cmd = "kubectl get secrets | cut -d ' ' -f 1 $grepCmdWithPipe";

    chomp(my @secrets = `$cmd`);
    $? != 0 and die "Could not run kubectl - need to run avp? bad grep?";

    return @secrets;
}

sub getSecret {
    my @secretList = getSecrets(@_);

    my $index = 0;
    foreach my $secret (@secretList) {
        my $pos = ++$index;
        say "${pos}) $secret";
    }

    print "which number? ";
    my $input = <STDIN>;

    if ($input !~ /^\d+$/) {
        die "Didn't get a number";
    }

    if ($input < 1 || $input > $index){
        die "invalid number";
    }

    return "$secretList[$input -1]";
}

#####################################################
# Main Script
#####################################################

chomp(my $env = `kubens --current`);
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
my $secret = getSecret($grepArgs);

my $command = "kubectl get secret $secret -n $env -oyaml | decode_secret_yaml";
say "vvvvvvvvvvvv Outputting SECRETS for vvvvvvvvvvvvvvvv";
say "Environment: $env";
say "Secret: $secret";
say "Command: $command";
say "^^^^^^^^^^^^ Outputting SECRETS for ^^^^^^^^^^^^^^^^";

sleep(1);

system $command;
