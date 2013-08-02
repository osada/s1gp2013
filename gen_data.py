#!/usr/bin/env python
# -*- coding: utf-8; tab-width: 4 -*-

import numpy as np
import scipy, sys, random, math
from scipy.stats import norm, chi2

def print_cdf():
    print "Nothing"

if len(sys.argv) != 3:
    print "Usage: ./%s <data_size> <seed>" % sys.argv[0] 
    exit(1)

# Input Arguments
data_size    = int(sys.argv[1])
seed         = int(sys.argv[2])

# Constant Variables
amount_min    = 50000
amount_wm     = 180000     # Watermark for calculating RATE (near average)
month_offset  = 201401
month_org_lim = 24          # Can not start to organize over month_wm
month_col_lim = 30          # Can not wait to collect over month_max
period_min    = 4
period_max    = 24
rate_min      = 0.0100
rate_max      = 0.1200
trial_max     = 100

# Specifying random seed
random.seed(seed)      # different from belows
np.random.seed(seed)   # the same as scipy.random.seed

def get_amount(amount_min):
    amount = 0
    while amount < amount_min:
        rv = random.uniform(0, 1)
        if rv < 0.65:
            amount = int(norm.rvs(loc=100, scale=35)) * 1000
        elif rv < 0.9:
            amount = int(norm.rvs(loc=285, scale=80)) * 1000
        else:
            amount = int(norm.rvs(loc=450, scale=10)) * 1000
    return amount

def get_rate(amount):
    rate  = 0.0
    count = 0 
    while rate < rate_min or rate > rate_max or count < trial_max:
        rv = random.uniform(0, 1)
        if rv < 0.8 * amount / amount_wm:
            rate = int(norm.rvs(loc=35, scale=5)) / 1000.0
        elif rv < 0.9 * amount / amount_wm:
            rate = int(norm.rvs(loc=60, scale=10)) / 1000.0
        else:
            rate = int(norm.rvs(loc=25, scale=50)) / 1000.0
        # Adjusting rate using needs (rate of low-amount is forced be large)
        if amount < amount_wm:
            rate = round(rate * amount_wm / amount, 3) 
        # Break infinite loop
        if count == trial_max and (rate < rate_min or rate > rate_max):
            rate = round(random.uniform(rate_min, rate_max), 3)
        count += 1
    return rate

def get_period(min, max):
    # period = random.randint(min, max)
    period = 0
    while period < min or period > max:
        rv = random.uniform(0, 1)
        if rv < 0.45:
            period = int(norm.rvs(loc=12, scale=2))
        elif rv < 0.8:
            period = int(norm.rvs(loc=6, scale=1))
        else:
            period = int(norm.rvs(loc=14, scale=4))
    return period

def get_month(off, org_lim, col_lim, period):
    start = 100000   # Sentinel
    while start + period > col_lim or start < 0:
        # Emulate seasonality
        rv = random.uniform(0, 1)
        if rv < 0.3:
            start = int(norm.rvs(loc=6, scale=1))
        elif rv < 0.55:
            start = int(norm.rvs(loc=12, scale=1))
        elif rv < 0.75:
            start = int(norm.rvs(loc=18, scale=1))
        elif rv < 0.9:
            start = int(norm.rvs(loc=24, scale=1))
        else:
            start = int(norm.rvs(loc=4, scale=12))

    month = math.floor(off / 100) * 100 \
        + (off % 100 + start % 12) % 12 \
        + math.floor((off % 100 + start % 12) / 12) * 100 \
        + math.floor(start / 12) * 100
    if month % 100 == 0:
        month = month - 100 + 12

    return int(month)


# Customer ID: 0 -- data_size
for id in range(data_size):
    amount = get_amount(amount_min)
    rate   = get_rate(amount)
    period = get_period(period_min, period_max)
    month  = get_month(month_offset, month_org_lim, month_col_lim, period)

    # start_mon  = random.randint(0, period_max - period_min)
    # from_mon = month_offset + start_mon % 12 + math.floor(start_mon / 12) * 100
    print "%d\t%s\t%s\t%d\t%d" % (id, amount, rate, month, period)

