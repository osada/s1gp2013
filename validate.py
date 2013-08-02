#!/usr/bin/env python
# -*- coding: utf-8; tab-width: 4 -*-

import sys, fileinput, math, datetime

def print_cdf():
    print "Nothing"

if len(sys.argv) != 3:
    print "Usage: ./%s <fund> <needers.txt> < <debtors.txt>" % sys.argv[0] 
    exit(1)

# Get now
d = datetime.datetime.today()

# Input Variables
fund        = int(sys.argv[1])
n_filename  = sys.argv[2]

# Output Variables
gain        = 0

# Constant Variables
month_start = 201301
month_end   = 202512
r_filename  = "record_" + d.strftime("%Y%m%d%H%M%S") + ".txt"

# Internal Variables
month_now   = month_start
used        = 0
needers     = []
debtors     = []

def get_maturity_month(n_month, n_period):
    m_month = math.floor(n_month / 100) * 100 \
        + (n_month % 100 + n_period % 12) % 12 \
        + math.floor((n_month % 100 + n_period % 12) / 12) * 100 \
        + math.floor(n_period / 12) * 100
    if m_month % 100 == 0:
        m_month = m_month - 100 + 12
    return m_month

def record():
    f = open(r_filename, "a")
    f.write(str(int(math.floor(month_now / 100))) + "/" + \
            str(int(math.floor(month_now % 100))) + "\t" + \
            str(fund) + "\t" + str(gain) + "\t" + str(used) + "\n")
    f.close()

### Main ###
# Read file into needers
f = open(n_filename, "r")
for line in f:
    needers.append(line.rstrip().split("\t"))
f.close()

# Read STDIN into debtors
for line in sys.stdin.readlines():
    debtors.append(line.rstrip().split("\t"))

# Sort by start_month(3) in neesers
needers.sort(key=lambda x:(x[3],x[0]))

# Initialize record file
f = open(r_filename, "w")
f.close()
record()

while month_now <= month_end:

    # print "now = %s" % month_now

    for needer in needers:
        n_id     = needer[0]
        n_amount = int(needer[1])
        n_rate   = float(needer[2])
        n_month  = int(needer[3])
        n_period = int(needer[4])

        for debtor in debtors:
            d_id = debtor[0]

            # Collecting loan and increase fund
            if d_id == n_id and \
                    month_now == get_maturity_month(n_month, n_period):
                # print "Collecting Loan (%s):" % n_id,
                this_gain = n_amount * n_rate * n_period / 12.0
                gain = gain + math.floor(this_gain)
                fund = fund + math.floor(this_gain)
                used = used - n_amount
                # print "gain = %s, new_used = %s, new_fund = %s" \
                #    % (gain, used, fund)
                break

            # Organizing loan and decrease fund if possible
            if d_id == n_id and month_now == n_month:
                # print "Organizing Loan (%s): amount = %s, fund = %s" \
                #    % (n_id, n_amount, fund),
                used = used + n_amount
                # print " new_used = %s" % used
                if used > fund:
                    print "ERROR: the amount can not be accepted."
                    sys.exit(1)
                break

    # Record Data
    record()

    # Incriment month_now
    if month_now % 100 == 12:
        month_now = month_now + 100 - 11
    else:
        month_now += 1

# Output results
print "Gain: %d" % gain
# OPTION: Output additional informations
