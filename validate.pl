# -*- tab-width: 4 -*-
#!/opt/local/bin/perl

#STDIN:    Debtors list
#$ARGV[0]: Fund
#$ARGV[1]: Needers list Filename

#Definition
$MONTH_START         = 201401;
$MONTH_END           = 201412;
$REASON_OK           = 0b00000000;
$REASON_NG_OVER_FUND = 0b00000001;
$REASON_NG_NO_NEEDER = 0b00000010;
$REASON_NG_CORRUPTED = 0b00000100;

if ($#ARGV != 1) {
    print "Error: missing argment\n";
    print "Usage: <this> <fund> <needers.txt> < <debtors.txt>\n";
    exit 1;
}

# Inout Variables
$FUND       = $ARGV[0];
$N_FILENAME = $ARGV[1];

# Output Variables
$USED   = 0;
$GAIN   = 0;
$REASON = $REASON_OK;

# Internal Variables
$MONTH_NOW = $MONTH_START;

# Read Needers List from $ARGV[1] using sort (UNIX command)
open(N_IN, "sort -n -k 4 $N_FILENAME |") or die("can not sort: $!");
@NEEDERS   = <N_IN>;
close(N_IN);

# Read Debtors List from STDIN (in no particular order)
@DEBTORS = <STDIN>;

# For checking duplicated debtors
@UNIQ_DEBTORS = ();

for ($MONTH_NOW = $MONTH_START; $MONTH_NOW <= $MONTH_END; $MONTH_NOW++) {

	print "--- Month: $MONTH_NOW ---\n";

    # Collecting loans
	for $DEBTOR (@DEBTORS) {
		chomp($DEBTOR);
		@DEBTOR_INFO = split(/\s+/, $DEBTOR);
		$D_ID     = $DEBTOR_INFO[0];

		for $NEEDER (@NEEDERS) {
			chomp($NEEDER);
			@NEEDER_INFO = split(/\s+/, $NEEDER);
			$N_ID     = $NEEDER_INFO[0];
			$N_NEED   = $NEEDER_INFO[1];
			$N_RATE   = $NEEDER_INFO[2];
			$N_MONTH  = $NEEDER_INFO[3];
			$N_PERIOD = $NEEDER_INFO[4];

			if ($D_ID == $N_ID && $MONTH_NOW == $N_MONTH + $N_PERIOD) {
				print "Collect  ($N_ID) USED: $USED - $N_NEED = ";
				$FUND = $FUND + $N_NEED * $N_RATE * $N_PERIOD / 12.0;
				$USED = $USED - $N_NEED;
				print "$USED, Fund = $FUND\n";
				last;
			}
		}
	}

# Organizing loans
	for $DEBTOR (@DEBTORS) {
		chomp($DEBTOR);
		@DEBTOR_INFO = split(/\s+/, $DEBTOR);
		$D_ID     = $DEBTOR_INFO[0];

		for $NEEDER (@NEEDERS) {
			chomp($NEEDER);
			@NEEDER_INFO = split(/\s+/, $NEEDER);
			$N_ID     = $NEEDER_INFO[0];
			$N_NEED   = $NEEDER_INFO[1];
			$N_RATE   = $NEEDER_INFO[2];
			$N_MONTH  = $NEEDER_INFO[3];
			$N_PERIOD = $NEEDER_INFO[4];

			if ($D_ID == $N_ID && $MONTH_NOW == $N_MONTH) {
				print "Organize ($N_ID) USED: $USED + $N_NEED = ";
				print $USED + $N_NEED . ", Fund: $FUND\n";
				if ($FUND < $USED + $N_NEED) {
					$REASON = $REASON_NG_OVER_FUND;
					print " => NG (Over fund)";
					exit(1);
				}
				$USED = $USED + $N_NEED;
				$GAIN = $GAIN + $N_NEED * $N_RATE * $N_PERIOD / 12.0;
				last;
			}
		}
	}
}

print "=> OK (GAIN = $GAIN)\n";
