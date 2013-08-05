#!/usr/bin/env python
# -*- coding: utf-8; tab-width: 4 -*-

import numpy as np
import scipy, sys, random, math
from scipy.stats import norm, chi2, gengamma

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
amount_wm     = 210000     # Watermark for calculating RATE (near average)
amount_max    = 700000
month_offset  = 201401
month_org_lim = 24         # Can not start to organize over month_wm
month_col_lim = 36         # Can not wait to collect over month_max
period_min    = 6
period_max    = 24
rate_min      = 0.0380
rate_max      = 0.1200

# Specifying random seed
random.seed(seed)      # different from belows
np.random.seed(seed)   # the same as scipy.random.seed

def get_amount(amount_min):
    amount = 0
    while amount < amount_min or amount > amount_max:
        rv = random.uniform(0, 1)
        if rv < 0.4:
            amount = amount_max - int(chi2.rvs(2, loc=50, scale=400)) * 1000
        elif rv < 0.85:
            amount = amount_max - int(chi2.rvs(3, loc=220, scale=435)) * 1000
        else:
            amount = amount_max - int(norm.rvs(loc=595, scale=55)) * 1000
    return amount

def get_rate(amount, month, period):
    rate  = 0.0
    while rate < rate_min or rate > rate_max:
        rv = random.uniform(0, 1)
        if rv < 0.7:
            rate = int(norm.rvs(loc=65, scale=8)) / 1000.0
        elif rv < 0.9:
            rate = int(norm.rvs(loc=88, scale=2)) / 1000.0
        else:
            rate = int(norm.rvs(loc=35, scale=50)) / 1000.0

    # set low rate when period is small
    rate = rate + rate * (amount_wm - amount) * period / amount_wm / period_max

    # Campain  
    if month % 100 >= 10:
        rate = rate + 0.015

    # Adjusting
    rate = round(rate, 3)
    if rate < rate_min:
        rate = rate_min
    elif rate > rate_max:
        rate = rate_max

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


# gengamma a = k (sharp), c = theta (sharp:average)
def get_month(off, org_lim, col_lim, period):
    start = 100000   # Sentinel
    while start + period > col_lim or start < 0:
        # Emulate seasonality
        rv = random.uniform(0, 1)
        if rv < 0.35:
            start = int(gengamma.rvs(2, 3, loc=1, scale=5))
        elif rv < 0.65:
            start = int(norm.rvs(loc=9, scale=6))
        elif rv < 0.85:
            start = int(norm.rvs(loc=15, scale=8))
        else:
            start = int(random.uniform(0, org_lim))

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
    period = get_period(period_min, period_max)
    month  = get_month(month_offset, month_org_lim, month_col_lim, period)
    rate   = get_rate(amount, month, period)

    # start_mon  = random.randint(0, period_max - period_min)
    # from_mon = month_offset + start_mon % 12 + math.floor(start_mon / 12) * 100
    print "%d\t%s\t%s\t%d\t%d" % (id, amount, rate, month, period)

