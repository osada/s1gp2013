#!/opt/local/bin/perl

#$ARGV[0]: Number of Data
#$ARGV[1]: Seed

if ($#ARGV != 1) {
    print "Error: missing argment\n";
    print "Usage: <this> <datanum> <seed>\n";
    exit 1;
}

$DATANUM = $ARGV[0];
$SEED    = $ARGV[1];

# Set Seed
srand $SEED;

# Generate Data
foreach (1 .. $DATANUM) {
    $ID     = $_;
    # Need Money: 3000--10000 Yen
    $NEED   = int(rand(700) + 1 + 300) * 10;
    # Interest Rate: 0.010 -- 0.192
    $RATE   = int(rand(182) + 1 + 10) / 1000; 
    # From/To: 201401 -- 201412 (Minimum 3 month)
    $FROM   = int(rand(9) + 1 + 201400);
    $PERIOD = int(rand(201412 - $FROM - 1)) + 3;

    # Output
    print $ID . "\t" . $NEED . "\t" . $RATE . "\t" . $FROM . "\t" . $PERIOD . "\n";
}



