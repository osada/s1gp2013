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
need_min     = 4000
month_offset = 201401
period_min   = 3
period_max   = 24
rate_min     = 0.0100
rate_max     = 0.1920

# Specifying random seed
random.seed(seed)      # different from belows
np.random.seed(seed)   # the same as scipy.random.seed

## Test Data
#offset = range(10)
#print offset
#out = 0.3 * norm.rvs(loc=0, scale=1, size=10) 
#+ 0.2 * norm.rvs(loc=3, scale=3, size=10) 
#+ 0.5 * norm.rvs(loc=1, scale=3, size=10) + offset
#print out

def get_need(need_min):
    need = 0
    while need < need_min:
        rv = random.uniform(0, 1)
        if rv < 0.5:
            need = int(norm.rvs(loc=800, scale=400)) * 10
        elif rv < 0.65:
            need = int(norm.rvs(loc=1300, scale=100)) * 10
        else:
            need = int(norm.rvs(loc=2000, scale=200)) * 10
    return need

def get_rate(need):
    rate = 0
    # select rate concidered from need
    while rate < rate_min || rate > rate_max
        rv = random.uniform(0, 1)
        if rv < 0.5:
            need = int(norm.rvs(loc=800, scale=400)) * 10
        elif rv < 0.65:
            need = int(norm.rvs(loc=1300, scale=100)) * 10
        else:
            need = int(norm.rvs(loc=2000, scale=200)) * 10
    return rate

# Customer ID: 0 -- data_size
for id in range(data_size):
    # Need Money: 4000 --
    need = get_need(need_min)
    # Interest Rate: 0.0100 -- 0.1920
    rate = round(random.uniform(rate_min, rate_max), 4)
    # From Month: 201401 -- 201510
    start_mon  = random.randint(0, period_max - period_min)
    from_mon = month_offset + start_mon % 12 + math.floor(start_mon / 12) * 100

    # Period Month
    period_mon = random.randint(period_min, period_max - start_mon)
    
    print "%d\t%s\t%s\t%d\t%d" % (id, need, rate, from_mon, period_mon)
