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

# load the dev settings from http://locator.dev.allenpress.net/applications/46/settings
BEGIN {
    $ENV{locator} = 'locator.dev.allenpress.net';
}

# set up an object with the 'test' settings
my $thing_test = AP::PDF::Renamer->new(
            locator => {
                        app_name => 'AP::PDF::Renamer',
                        key => 'slitebresi' 
                    },
            logger => {
                        level       => 'trace',
                        destination => { off => 1 },
                        #destination => { logfile => 't/logs/test_05_test.log' },
                    }
);
$thing_test->{run_mode} = 'test';
$thing_test->{success} = 'true';

# set up an object with the 'live' settings
my $thing_live = AP::PDF::Renamer->new(
            locator => {
                        app_name => 'AP::PDF::Renamer', 
                        key => 'slitebresi'
                    },
            logger => {
                        level       => 'trace', # options: { trace | debug | info | warning | error | fatal }
                        destination => { off => 1, }
                        #destination => { logfile => 't/logs/test_05_live.log' },
                    }
);
$thing_live->{run_mode} = 'live';
$thing_live->{success} = 'true';

# get the Locator settings independently for reference
my $settings = $thing_live->_locator->get_settings_hashref;

# run the 'test' version and check the paths
$thing_test->_get_paths;
ok( $thing_test->{path}->{input_folder} eq 't/file_in/', 'check test input folder file path' );
ok( $thing_test->{path}->{output_folder} eq 't/file_out/', 'check test output folder file path' );
ok( ! defined $thing_test->{path}->{output_folder_sent}, 'check test output folder file path' );
ok( $thing_test->{path}->{trigger_in_folder} eq 't/trigger_in/', 'check test trigger input folder file path' );
ok( $thing_test->{path}->{trigger_out_folder} eq 't/trigger_out/', 'check test trigger output folder file path' );
ok( $thing_test->{path}->{activity_log} =~ m{t\/logs\/activity_}xmsi, 'check test activity log folder file path' );
ok( $thing_test->{path}->{error_log} =~ m{t\/logs\/error_}xmsi, 'check test error log folder file path' );

# run the 'live' version and check the paths
$thing_live->_get_paths;
ok( ! defined $thing_live->{path}->{input_folder}, 'check live input folder file path' );
ok( $thing_live->{path}->{output_folder} eq $settings->{file_out_path}, 'check live trigger input folder file path' );
ok( ! defined $thing_live->{path}->{output_folder_sent}, 'check live output folder file path' );
ok( $thing_live->{path}->{trigger_in_folder} eq $settings->{trigger_in_path}, 'check live trigger input folder file path' );
ok( $thing_live->{path}->{trigger_out_folder} eq $settings->{trigger_out_path}, 'check live trigger output folder file path' );
ok( $thing_live->{path}->{activity_log} =~ m{$settings->{log_path}activity_}xmsi, 'check live activity log folder file path' );
ok( $thing_live->{path}->{error_log} =~ m{$settings->{log_path}errors_}xmsi, 'check live error log folder file path' );


# fin
done_testing();
