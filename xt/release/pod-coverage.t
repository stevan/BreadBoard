#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Test::Requires {
    'Test::Pod::Coverage' => '1.04',    # skip all if not installed
    'Pod::Coverage::TrustPod' => '0',
};

# This is a stripped down version of all_pod_coverage_ok which lets us
# vary the trustme parameter per module.
my @modules
    = grep { !/GraphViz/ } all_modules();
plan tests => scalar @modules;

for my $module (sort @modules) {
    pod_coverage_ok($module, { coverage_class => 'Pod::Coverage::TrustPod' },
                    "Pod coverage for $module");
}
