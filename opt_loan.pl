#!/opt/local/bin/perl
# -*- coding: utf-8; tab-width: 4 -*-

#STDIN:    Needs List
#$ARGV[0]: Fund
#$ARGV[1]: Trial Times
#$ARGV[2]: Seed

use POSIX;
use warnings;

#Definition
$MONTH_START   = 201301;
$MONTH_END     = 202512;
$ATTEMPT_LIMIT = 100;

if ($#ARGV != 2) {
    print "Error: missing argment\n";
    print "Usage: <this> <fund> <trial_times> <seed> < <needers.txt>\n";
    exit 1;
}

$FUND  = $ARGV[0];
$TRIAL = $ARGV[1];
$SEED  = $ARGV[2];

# Set Seed
srand $SEED;

# Initialize Output Variables
$GAIN_MAX            = -1;
@DEBTORS_MAX         = ();
$STAT_CANCEL_BY_DUP  = 0;
$STAT_CANCEL_BY_OVER = 0;
$STAT_UPDATE         = 0;

# Read Data
@NEEDERS = <STDIN>;

foreach (1 .. $TRIAL) {
    # Initialization Internal variables
    $FUND      = $ARGV[0];
    $USED      = 0;
    $GAIN      = 0;
    @DEBTORS   = ();

    #print "--- Traial: $_ ---\n";
    $MONTH_NOW = $MONTH_START;
	while ($MONTH_NOW <= $MONTH_END) {

		#print "MONTH: $MONTH_NOW, (FUND, USED) = ($FUND, $USED)\n";
		# Collecting loans
		foreach $DEBTOR (@DEBTORS) {
			chomp($DEBTOR);
			@DEBTOR_INFO = split(/\s+/, $DEBTOR);
			$ID     = $DEBTOR_INFO[0];
			$AMOUNT = $DEBTOR_INFO[1];
			$RATE   = $DEBTOR_INFO[2];
			$MONTH  = $DEBTOR_INFO[3];
			$PERIOD = $DEBTOR_INFO[4];

			# Convert Redemption Period to Month
			$M_MONTH = floor($MONTH / 100.0) * 100
				+ ($MONTH % 100 + $PERIOD % 12) % 12
				+ floor(($MONTH % 100 + $PERIOD % 12) / 12) * 100
				+ floor($PERIOD / 12) * 100;
			if ($M_MONTH % 100 == 0) {
				$M_MONTH = $M_MONTH - 100 + 12;
			}

			if ($MONTH_NOW == $M_MONTH) {
				$THIS_GAIN = $AMOUNT * $RATE * $PERIOD / 12.0;
				$GAIN = $GAIN + floor($THIS_GAIN);
				$FUND = $FUND + floor($THIS_GAIN);
				$USED = $USED - $AMOUNT;
			}
		}
		#print "collecting -> ($FUND, $USED)\n";

		# Organizing loans
	  LOOPMARK: for ($ATTEMPT = 0; $USED < $FUND && $ATTEMPT < $ATTEMPT_LIMIT;
					 $ATTEMPT++) {
		  # Select one needer
		  $ELEM = int(rand($#NEEDERS + 1));
		  $NEEDER = $NEEDERS[$ELEM];
		  
		  # get needer's information
		  chomp($NEEDER);
		  @NEEDER_INFO = split(/\s+/, $NEEDER);
		  $ID     = $NEEDER_INFO[0];
		  $AMOUNT = $NEEDER_INFO[1];
		  $RATE   = $NEEDER_INFO[2];
		  $MONTH  = $NEEDER_INFO[3];
		  $PERIOD = $NEEDER_INFO[4]; 
		  
		  # drop a candidate having not $MONTH_NOW
		  if ($MONTH != $MONTH_NOW) {next LOOPMARK;}

		  # check duplicated
		  foreach $DEBTOR (@DEBTORS) {
			  chomp($DEBTOR);
			  @DEBTOR_INFO = split(/\s+/, $DEBTOR);
			  $D_ID     = $DEBTOR_INFO[0];
			  if ($ID == $D_ID) {
				  $STAT_CANCEL_BY_DUP++;
				  next LOOPMARK;
			  }
		  }
		  		  
		  # add loan list if possible
		  if ($USED + $AMOUNT <= $FUND) {
			  push(@DEBTORS, $NEEDER);
			  $USED = $USED + $AMOUNT;
		  } else {
			  # few money to organize loans
			  $STAT_CANCEL_BY_OVER++;
			  last LOOPMARK;
		  }
	  } # End LOOPMARK
		#print "organizing -> ($FUND, $AMOUNT)\n";
		#print "GAIN: $GAIN, USED_RATE: " . $USED / $FUND ."\n\n";
		
		# Incriment MONTH_NOW
		if ($MONTH_NOW % 100 == 12) {
			$MONTH_NOW = $MONTH_NOW + 100 - 11;
		} else {
			$MONTH_NOW++;
		}
    }
	
	if ($GAIN > $GAIN_MAX) {
		$STAT_UPDATE++;
		$GAIN_MAX = $GAIN;
		@DEBTORS_MAX = @DEBTORS;
	}
}

# Output Results
print "GAIN_MAX = $GAIN_MAX\n";
foreach (@DEBTORS_MAX) {
	print "$_\n";
}
