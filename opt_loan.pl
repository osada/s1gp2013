#!/opt/local/bin/perl

#STDIN:    Needs List
#$ARGV[0]: Fund
#$ARGV[1]: Trial Times
#$ARGV[2]: Seed

#Definition
$MONTH_START   = 201401;
$MONTH_END     = 201412;
$ATTEMPT_LIMIT = 100;

if ($#ARGV != 2) {
    print "Error: missing argment\n";
    print "Usage: <this> <fund> <trial_times> <seed>\n";
    exit 1;
}

$FUND  = $ARGV[0];
$TRIAL = $ARGV[1];
$SEED  = $ARGV[2];

# Set Seed
srand $SEED;

# Initialize Output Variables
$GAIN_MAX            = -1;
$USED_RATE_MAX       = 0;
@LOAN_LIST_MAX       = ();
$STAT_CANCEL_BY_DUP  = 0;
$STAT_CANCEL_BY_OVER = 0;
$STAT_UPDATE         = 0;

# Read Data
@NEED_LIST = <STDIN>;

foreach (1 .. $TRIAL) {
    # Initialization
	$FUND      = $ARGV[0];
    $USED      = 0;
	$USED_RATE = 0;
    $GAIN      = 0;
    @LOAN_LIST = ();

	#print "--- Traial: $_ ---\n";

	for ($MONTH_NOW = $MONTH_START; $MONTH_NOW <= $MONTH_END; $MONTH_NOW++) {
		#print "MONTH: $MONTH_NOW, (FUND, USED) = ($FUND, $USED)\n";
		# Collecting loans
		foreach $CUSTOMER (@LOAN_LIST) {
			chomp($CUSTOMER);
			@CUSTOMER_INFO = split(/\s+/, $CUSTOMER);
			$ID     = $CUSTOMER_INFO[0];
			$NEED   = $CUSTOMER_INFO[1];
			$RATE   = $CUSTOMER_INFO[2];
			$MONTH  = $CUSTOMER_INFO[3];
			$PERIOD = $CUSTOMER_INFO[4];
			
			if ($MONTH_NOW == $MONTH + $PERIOD) {
				$FUND = $FUND + $NEED * $RATE * $PERIOD / 12.0;
				$USED = $USED - $NEED;
			}
		}
		#print "clearing -> ($FUND, $USED)\n";
		# Loaning
	  LOOPMARK: for ($ATTEMPT = 0; $USED < $FUND && $ATTEMPT < $ATTEMPT_LIMIT;
					 $ATTEMPT++) {
		  # Select one data
		  $ELEM = int(rand($#NEED_LIST + 1));
		  $NEEDER = $NEED_LIST[$ELEM];
		  
		  # Cleansing data
		  chomp($NEEDER);
		  @NEEDER_INFO = split(/\s+/, $NEEDER);
		  $ID     = $NEEDER_INFO[0];
		  $NEED   = $NEEDER_INFO[1];
		  $RATE   = $NEEDER_INFO[2];
		  $MONTH  = $NEEDER_INFO[3];
		  $PERIOD = $NEEDER_INFO[4]; 
		  
		  # check duplicated loan
		  foreach (@LOAN_LIST) {
			  if ($ID == $_) {
				  $STAT_CANCEL_BY_DUP++;
				  next LOOPMARK;
			  }
		  }
		  
		  # drop a candidate having not $MONTH_NOW
		  if ($MONTH != $MONTH_NOW) {next LOOPMARK;}
		  
		  # drop a candidate over period
		  if ($MONTH_END < $MONTH + $PERIOD) {next LOOPMARK;}

		  # add loan list if possible
		  if ($USED + $NEED <= $FUND) {
			  push(@LOAN_LIST, $NEEDER);
			  $USED = $USED + $NEED;
			  $GAIN = $GAIN + $NEED * $RATE * $PERIOD / 12.0;
		  }
		  else {
			  last LOOPMARK;
		  }
	  }
		$USED_RATE = $USED_RATE + $USED / $FUND / 12.0;
		#print "loaning -> ($FUND, $USED)\n";
		#print "GAIN: $GAIN, USED_RATE: " . $USED / $FUND ."\n\n"

	}

	if ($GAIN > $GAIN_MAX) {
			$GAIN_MAX = $GAIN;
			$USED_RATE_MAX = $USED_RATE;
			@LOAN_LIST_MAX = @LOAN_LIST;
		}
}

# Output Results
print "GAIN_MAX = $GAIN_MAX, USED_RATE_MAX = $USED_RATE_MAX\n";
foreach (@LOAN_LIST_MAX) {
	print "$_\n";
}
