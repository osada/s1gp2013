#!/opt/local/bin/perl

#STDIN:    Needs List    
#$ARGV[0]: Fund
#$ARGV[1]: Trial Times
#$ARGV[2]: Seed

#Definition
$MONTH_START = 201401;
$MONTH_END   = 201412;

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
$USED_MAX  = -1;
$GAIN_MAX  = -1;
@LOAN_LIST_MAX = ();

# Read Data
@NEED_LIST = <STDIN>;

foreach (1 .. $TRIAL) {
    # Initialization
    $USED = 0;
    $GAIN = 0;
    $MONTH_NOW = $MONTH_START;
    @LOAN_LIST = ();

    LOOPMARK: while ($USED < $FUND) {
	# Select one data
	$ELEM = int(rand($#NEED_LIST + 1));
	$NEEDER = $NEED_LIST[$ELEM];
	
	# Cleansing data
	chomp($NEEDER);
	@NEEDER_INFO = split(/\s+/, $NEEDER);
	$ID   = $NEEDER_INFO[0];
	$NEED = $NEEDER_INFO[1]; 
	$RATE = $NEEDER_INFO[2];
	$RISK = $NEEDER_INFO[3];
    
	# check duplicated loan
	foreach (@LOAN_LIST) {
	    if ($ID == $_) {
		next LOOPMARK;
	    }
	}

	# drop a candidate with higher risk than interest rate
	if ($RATE < $RISK) {
	    next LOOPMARK;
	}

	# add loan list if possible
	if ($USED + $NEED <= $FUND) {
	    push(@LOAN_LIST, $ID);
	    $USED = $USED + $NEED;
	    $GAIN = $GAIN + $NEED * $RATE;
	    $LOST = $LOST + $NEED * $RISK;
	}
	else {
	    last LOOPMARK;
	}
    }

    $SUM = $GAIN - $LOST;

    if ($SUM > $SUM_MAX) {
	$SUM_MAX  = $SUM;
	$GAIN_MAX = $GAIN;
	$LOST_MIN = $LOST;
	$USED_MAX = $USED;
	@LOAN_LIST_MAX = @LOAN_LIST
    }
}

# Output Results
print "SUM_MAX = $SUM_MAX (GAIN_MAX = $GAIN_MAX, LOST_MIN = $LOST_MIN\n";
print "USED_MAX / FUND = $USED_MAX / $FUND (". $USED_MAX/$FUND .")\n";
foreach $LOAN_ID (@LOAN_LIST_MAX) {
    foreach $NEEDER (@NEED_LIST) {
	chomp($NEEDER);
	@NEEDER_INFO = split(/\s+/, $NEEDER);
	if ($LOAN_ID == $NEEDER_INFO[0]) {
	    print "$NEEDER\n";
	    last;
	}
    }
}

#print "$ID\t$NEED\t$RATE\t$RISK\n";



