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
                        #destination => { logfile => 't/logs/test_06.log' },
                    }
);

#GENERAL TEST

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

# do the testing
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{first_letter} eq 't',                'clean first_letter' );
ok( $thing->{job_data}->{1}->{jcode} eq 'test',                    'clean jcode' );
ok( $thing->{job_data}->{1}->{alt_jcode} eq 'test',                'clean alt_jcode' );
ok( $thing->{job_data}->{1}->{vol} eq '01',                        'clean vol' );
ok( $thing->{job_data}->{1}->{vol_padded} eq '01',                 'clean vol_padded' );
ok( $thing->{job_data}->{1}->{vol_trimmed} eq '1',                 'clean vol_trimmed' );
ok( $thing->{job_data}->{1}->{iss} eq '02',                        'clean iss' );
ok( $thing->{job_data}->{1}->{iss_padded} eq '02',                 'clean iss_padded' );
ok( $thing->{job_data}->{1}->{iss_trimmed} eq '2',                 'clean iss_trimmed' );
ok( $thing->{job_data}->{1}->{month} eq 'JA14',                    'clean month' );
ok( $thing->{job_data}->{1}->{special} eq 'no_special',            'clean special' );
ok( $thing->{job_data}->{1}->{ap_num} eq '03',                     'clean ap_num' );
ok( $thing->{job_data}->{1}->{cust_num} eq '987',                  'clean cust_num' );
ok( $thing->{job_data}->{1}->{authors} eq 'Schubert',              'clean authors' );
ok( $thing->{job_data}->{1}->{authors_first} eq 'Schubert',        'clean authors_first' );
ok( $thing->{job_data}->{1}->{cor_author} eq 'Schubert',           'clean cor_author' );
ok( $thing->{job_data}->{1}->{cor_author_trunc} eq 'Schu',         'clean cor_author_trunc' );
ok( $thing->{job_data}->{1}->{beg_pg} eq '100',                    'clean beg_pg' );
ok( $thing->{job_data}->{1}->{end_pg} eq '200',                    'clean end_pg' );
ok( $thing->{job_data}->{1}->{cycle} eq '1xo',                     'clean cycle' );
ok( $thing->{job_data}->{1}->{file_type} eq 'pdf',                 'clean file_type' );

# SPECIFIC TESTS
# keep data from above, but change things out to test

# lowercase jcode
$thing->{job_data}->{1}->{jcode} = 'TEST';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{first_letter} eq 't',                'lowercase first_letter' );
ok( $thing->{job_data}->{1}->{jcode} eq 'test',                    'lowercase jcode' );
ok( $thing->{job_data}->{1}->{alt_jcode} eq 'test',                'lowercase alt_jcode' );

# alt_jcode for BIRE
$thing->{job_data}->{1}->{jcode} = 'bire';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{first_letter} eq 'b',                'alt_jcode bire first_letter' );
ok( $thing->{job_data}->{1}->{jcode} eq 'bire',                    'alt_jcode bire jcode' );
ok( $thing->{job_data}->{1}->{alt_jcode} eq 'bor',                 'alt_jcode bire alt_jcode' );

# alt_jcode for HEPR
$thing->{job_data}->{1}->{jcode} = 'hepr';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{first_letter} eq 'h',                'alt_jcode hepr first_letter' );
ok( $thing->{job_data}->{1}->{jcode} eq 'hepr',                    'alt_jcode hepr jcode' );
ok( $thing->{job_data}->{1}->{alt_jcode} eq 'ajhp',                'alt_jcode hepr alt_jcode' );

# alt_jcode for MLAB
$thing->{job_data}->{1}->{jcode} = 'mlab';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{first_letter} eq 'm',                'alt_jcode mlab first_letter' );
ok( $thing->{job_data}->{1}->{jcode} eq 'mlab',                    'alt_jcode mlab jcode' );
ok( $thing->{job_data}->{1}->{alt_jcode} eq 'jmla',                'alt_jcode mlab alt_jcode' );

# corresponding author cleanup
$thing->{job_data}->{1}->{cor_author} = 'Charlotte Schubert';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{cor_author} eq 'Schubert',           'cor_author last name only' );
ok( $thing->{job_data}->{1}->{cor_author_trunc} eq 'Schu',         'cor_author last name truncate' );

# corresponding author whitespace cleanup
$thing->{job_data}->{1}->{cor_author} = ' Charlotte Schubert ';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{cor_author} eq 'Schubert',           'cor_author extra white space' );
ok( $thing->{job_data}->{1}->{cor_author_trunc} eq 'Schu',         'cor_author_trunc extra white space' );

# corresponding author two names
$thing->{job_data}->{1}->{cor_author} = 'Smith and Jones';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{cor_author} eq 'Jones',              'cor_author two names' );
ok( $thing->{job_data}->{1}->{cor_author_trunc} eq 'Jone',         'cor_author_trunc two names' );

# corresponding author ampersand
$thing->{job_data}->{1}->{cor_author} = 'Smith & Jones';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{cor_author} eq 'Jones',              'cor_author ampersand' );
ok( $thing->{job_data}->{1}->{cor_author_trunc} eq 'Jone',         'cor_author_trunc ampersand' );

# corresponding author et al
$thing->{job_data}->{1}->{cor_author} = 'Smith et al.';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{cor_author} eq 'Smith',              'cor_author et al' );
ok( $thing->{job_data}->{1}->{cor_author_trunc} eq 'Smit',         'cor_author_trunc et al' );

# authors clean up
$thing->{job_data}->{1}->{authors} = 'Schubert';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{authors} eq 'Schubert',              'authors cleanup' );
ok( $thing->{job_data}->{1}->{authors_first} eq 'Schubert',        'authors_first cleanup' );

# authors two names
$thing->{job_data}->{1}->{authors} = 'Smith and Jones';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{authors} eq 'Smith and Jones',       'authors two names' );
ok( $thing->{job_data}->{1}->{authors_first} eq 'Smith',           'authors_first two names' );

# authors three names
$thing->{job_data}->{1}->{authors} = 'Smith, Jones, and Clark';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{authors} eq 'Smith, Jones, and Clark','authors three names' );
ok( $thing->{job_data}->{1}->{authors_first} eq 'Smith',           'authors_first three names' );

# authors ampersand
$thing->{job_data}->{1}->{authors} = 'Smith & Jones';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{authors} eq 'Smith and Jones',       'authors two names' );
ok( $thing->{job_data}->{1}->{authors_first} eq 'Smith',           'authors_first two names' );

# authors et al
$thing->{job_data}->{1}->{authors} = 'Smith et al.';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{authors} eq 'Smith',                 'authors two names' );
ok( $thing->{job_data}->{1}->{authors_first} eq 'Smith',           'authors_first two names' );

# no page range numbers
$thing->{job_data}->{1}->{beg_pg} = 'no_beg_pg';
$thing->{job_data}->{1}->{end_pg} = 'no_end_pg';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{beg_pg} eq '0',                      'no begining page number' );
ok( $thing->{job_data}->{1}->{end_pg} eq '0',                      'no ending page number' );

# volume number cleanup
$thing->{job_data}->{1}->{vol} = '01';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{vol} eq '01',                        'volume number' );
ok( $thing->{job_data}->{1}->{vol_trimmed} eq '1',                 'volume number trimmed' );
ok( $thing->{job_data}->{1}->{vol_padded} eq '01',                 'volume number padded' );

# volume number extra padding
$thing->{job_data}->{1}->{vol} = '0001';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{vol} eq '0001',                      'extra padded volume number' );
ok( $thing->{job_data}->{1}->{vol_trimmed} eq '1',                 'extra padded volume number - trimmed' );
ok( $thing->{job_data}->{1}->{vol_padded} eq '01',                 'extra padded volume number - normal padding' );

# volume number no padding
$thing->{job_data}->{1}->{vol} = '1';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{vol} eq '1',                         'no padded volume number' );
ok( $thing->{job_data}->{1}->{vol_trimmed} eq '1',                 'no padded volume number - trimmed' );
ok( $thing->{job_data}->{1}->{vol_padded} eq '01',                 'no padded volume number - normal padding' );

# volume number 3 digit
$thing->{job_data}->{1}->{vol} = '123';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{vol} eq '123',                       'three digit volume number' );
ok( $thing->{job_data}->{1}->{vol_trimmed} eq '123',               'three digit volume number - trimmed' );
ok( $thing->{job_data}->{1}->{vol_padded} eq '123',                'three digit volume number - normal padding' );

# issue number cleanup
$thing->{job_data}->{1}->{iss} = '01';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{iss} eq '01',                        'issue number' );
ok( $thing->{job_data}->{1}->{iss_trimmed} eq '1',                 'issue number trimmed' );
ok( $thing->{job_data}->{1}->{iss_padded} eq '01',                 'issue number padded' );

# issue number extra padding
$thing->{job_data}->{1}->{iss} = '0001';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{iss} eq '0001',                      'extra padded issue number' );
ok( $thing->{job_data}->{1}->{iss_trimmed} eq '1',                 'extra padded issue number - trimmed' );
ok( $thing->{job_data}->{1}->{iss_padded} eq '01',                 'extra padded issue number - normal padding' );

# issue number no padding
$thing->{job_data}->{1}->{iss} = '1';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{iss} eq '1',                         'no padded issue number' );
ok( $thing->{job_data}->{1}->{iss_trimmed} eq '1',                 'no padded issue number - trimmed' );
ok( $thing->{job_data}->{1}->{iss_padded} eq '01',                 'no padded issue number - normal padding' );

# issue number 3 digit
$thing->{job_data}->{1}->{iss} = '123';
$thing->_cleanup_triggers;
ok( $thing->{job_data}->{1}->{iss} eq '123',                       'three digit issue number' );
ok( $thing->{job_data}->{1}->{iss_trimmed} eq '123',               'three digit issue number - trimmed' );
ok( $thing->{job_data}->{1}->{iss_padded} eq '123',                'three digit issue number - normal padding' );

# fin
done_testing();
