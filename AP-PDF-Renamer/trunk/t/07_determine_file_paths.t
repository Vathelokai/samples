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

# set up an object
my $thing = AP::PDF::Renamer->new(
            locator => {
                        app_name => 'AP::PDF::Renamer',
                        key => 'slitebresi' 
                    },
            logger => {
                        level       => 'trace',
                        destination => { off => 1 },
                        #destination => { logfile => 't/logs/test_07.log' },
                    }
);

# load the object
$thing->{run_mode} = 'test';
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
$thing->_cleanup_triggers;

# TEST MODE - 1XO
# do the testing for the 'test' mode folders
$thing->_determine_file_paths;
ok( $thing->{job_data}->{1}->{input_folder} eq 't/file_in/',           'test 1xo input folder path generated' );
ok( $thing->{job_data}->{1}->{output_folder_sent} eq 't/file_sent/',   'test 1xo output_sent folder path generated' );

# TEST MODE - REVISION
# use data from above, except...
$thing->{job_data}->{1}->{cycle} = 'revision';
$thing->_determine_file_paths;
ok( $thing->{job_data}->{1}->{input_folder} eq 't/file_in/',           'test rev input folder path generated' );
ok( $thing->{job_data}->{1}->{output_folder_sent} eq 't/file_sent/',   'test rev output_sent folder path generated' );

# LIVE MODE - 1XO
# use data from above, except...
$thing->{run_mode} = 'live';
$thing->{job_data}->{1}->{cycle} = '1xo';
$thing->_determine_file_paths;
ok( $thing->{job_data}->{1}->{input_folder} eq '/net/xinet/Production/t/test/live_jobs/test-01-02/_proofs/first/',               'live 1xo input folder path generated' );
ok( $thing->{job_data}->{1}->{output_folder_sent} eq '/net/xinet/Production/t/test/live_jobs/test-01-02/_proofs/first/_sent/',   'live 1xo output_sent folder path generated' );

# LIVE MODE - REVISION
$thing->{job_data}->{1}->{cycle} = 'revision';
$thing->_determine_file_paths;
ok( $thing->{job_data}->{1}->{input_folder} eq '/net/xinet/Production/t/test/live_jobs/test-01-02/_proofs/revisions/',               'live rev input folder path generated' );
ok( $thing->{job_data}->{1}->{output_folder_sent} eq '/net/xinet/Production/t/test/live_jobs/test-01-02/_proofs/revisions/_sent/',   'live rev output_sent folder path generated' );

# fin
done_testing();
