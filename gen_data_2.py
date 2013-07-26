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
amount_min    = 3000000    # 3M 
amount_wm     = 15000000   # Watermark for calculating RATE (near average)
month_offset  = 201401
month_org_lim = 36          # Can not start to organize over month_wm
month_col_lim = 60          # Can not wait to collect over month_max
period_min    = 12
period_max    = 36
rate_min      = 0.0235
rate_max      = 0.1180
trial_max     = 100

# Specifying random seed
random.seed(seed)      # different from belows
np.random.seed(seed)   # the same as scipy.random.seed

def get_amount(amount_min):
    amount = 0
    while amount < amount_min:
        rv = random.uniform(0, 1)
        if rv < 0.2:
            amount = int(norm.rvs(loc=9000, scale=3600)) * 1000
        elif rv < 0.35:
            amount = int(norm.rvs(loc=3000, scale=1200)) * 1000
        elif rv < 0.75:
            amount = int(norm.rvs(loc=10800, scale=2200)) * 1000
        else:
            amount = int(norm.rvs(loc=28000, scale=3200)) * 1000
    return amount

def get_rate(amount, month, period):
    rate  = 0.0
    while rate < rate_min or rate > rate_max:
        rv = random.uniform(0, 1)
        if rv < 0.8:
            rate = int(norm.rvs(loc=65, scale=8)) / 1000.0
        elif rv < 0.9:
            rate = int(norm.rvs(loc=88, scale=2)) / 1000.0
        else:
            rate = int(norm.rvs(loc=35, scale=50)) / 1000.0
        # Adjusting rate using needs (rate of low-amount is forced be large)
        if amount < amount_wm:
            rate = round(rate * amount_wm / amount, 3)

    # set low rate when period is small
    rate = rate * period / period_max

    # Campain
    if month % 100 == 4 or month % 100 == 5 or month % 100 == 2:
        rate = rate - 0.03
    if rate < rate_min:
        rate = rate_min

    return rate

def get_period(min, max):
    # period = random.randint(min, max)
    period = 0
    while period < min or period > max:
        rv = random.uniform(0, 1)
        if rv < 0.45:
            period = int(chi2.rvs(df=3, loc=24, scale=4))
        elif rv < 0.8:
            period = int(norm.rvs(loc=12, scale=3))
        else:
            period = int(norm.rvs(loc=28, scale=8))
    return period

def get_month(off, org_lim, col_lim, period):
    start = 100000   # Sentinel
    while start + period > col_lim or start < 0:
        # Emulate seasonality
        rv = random.uniform(0, 1)
        if rv < 0.3:
            start = int(norm.rvs(loc=4, scale=1))
        elif rv < 0.55:
            start = int(norm.rvs(loc=14, scale=1.5))
        elif rv < 0.75:
            start = int(norm.rvs(loc=16, scale=2))
        elif rv < 0.9:
            start = int(norm.rvs(loc=28, scale=2.2))
        else:
            start = int(norm.rvs(loc=5, scale=12))

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

    print "%d\t%s\t%s\t%d\t%d" % (id, amount, rate, month, period)

