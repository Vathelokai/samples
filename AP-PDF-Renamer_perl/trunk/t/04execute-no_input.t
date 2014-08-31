#!/usr/bin/env perl
use strict;
use warnings;

use AP::PDF::Renamer;
use Data::Dumper;                  # for error logs
    $Data::Dumper::Indent = 1;     #     makes dumper cleaner
    $Data::Dumper::Sortkeys = 1;   #     makes dumper cleaner
use Test::More;
use Text::Diff;

use_ok('AP::PDF::Renamer');

# try to run with no trigger files.  should end gracefully.
BEGIN {
    $ENV{locator} = 'locator.dev.allenpress.net';
}

# Instantiate
my $thing = AP::PDF::Renamer->new(
            locator => {
                        app_name => 'AP::PDF::Renamer',
                        key => 'slitebresi' 
                    },
            logger => {
                        level       => 'trace',
                        destination => { off => 1 },
                        #destination => { logfile => 't/logs/test_04.log' },
                    }
);

# scoop up all the triggers and work on them
    my $test = $thing->execute('test');
    ok( $test eq 'true',"execute() returned \$test: \'$test\'." ); # should change this to is()

# done
    done_testing();
