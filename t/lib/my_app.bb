#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use Bread::Board;

container 'MyApp' => as {

    service 'log_file' => "logfile.log";

    include "$FindBin::Bin/lib/logger.bb";

    service 'application' => (
        class        => 'MyApplication',
        dependencies => {
            logger => depends_on('logger'),
        }
    );
};