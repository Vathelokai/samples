#!/usr/bin/env perl
use strict;
use warnings;

use AP::PDF::Renamer;
use Data::Dumper;
    $Data::Dumper::Indent = 1;
    $Data::Dumper::Sortkeys = 1;
use Test::More;
use Text::Diff;

use_ok('AP::PDF::Renamer');

# load the dev settings from http://locator.dev.allenpress.net/applications/46/settings
BEGIN {
    $ENV{locator} = 'locator.dev.allenpress.net';
}

# set up an object with the 'live' settings
my $thing = AP::PDF::Renamer->new(
            locator => {
                        app_name => 'AP::PDF::Renamer',
                        key => 'slitebresi' 
                    },
            logger => {
                        level       => 'trace',
                        destination => { off => 1 },
                        #destination => { logfile => 't/logs/test_09.log' },
                    }
);

# load the object
$thing->{run_mode} = 'test';
$thing->{_logger}->{destinations}->{string} = 1;
$thing->{success} = 'true';
$thing->{job_data}->{1} = {
    jcode        => 'test',
    vol          => '01',
    iss          => '02',
    month        => 'JA14',
    special      => 'no_special',
    ap_num       => '03',
    cust_num     => '987',
    authors      => 'Schubert',
    cor_author   => 'Charlotte Schubert',
    beg_pg       => '100',
    end_pg       => '200',
    cycle        => '1xo',
};
$thing->_get_paths;
$thing->_cleanup_triggers;
$thing->_determine_file_paths;
$thing->_determine_output_file_names;

# set up test
$thing->{run_mode} = 'debug';
$thing->_debug_handler;

# do the testing
my $file_search = $thing->{path}->{error_log};
$file_search =~ s{error_}{debug_}xmsi;
my @file_list = glob($file_search);

ok( @file_list > 0,                'debug file generated' );

# cleanup
my $delete_search = $file_search;
$delete_search =~ s{^(.+debug_).+$}{$1*}xmsi;
my @delete_list = glob($delete_search);
unlink @delete_list;

# fin
done_testing();
