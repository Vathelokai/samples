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
                        #destination => { logfile => 't/logs/test_08.log' },
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

# TEST (uses the default case)
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'test_01_02-03_100_200.pdf',           'generate TEST file name' );

# keep it alphabetical after this
# society code may be used as prefix to keep things together

# AAAN - ACCH
$thing->{job_data}->{1}->{jcode} = 'acch';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'acch-01-02-03_987.pdf',               'generate AAAN - ACCH file name' );

# AAAN - ACCH strange customer number 1
$thing->{job_data}->{1}->{cust_num} = 'acch-987';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'acch-01-02-03_987.pdf',               'generate AAAN - ACCH strange customer number 1 file name' );
$thing->{job_data}->{1}->{cust_num} = '987';

# AAAN - ACCH strange customer number 2
$thing->{job_data}->{1}->{cust_num} = 'acch_987';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'acch-01-02-03_987.pdf',               'generate AAAN - ACCH strange customer number 2 file name' );
$thing->{job_data}->{1}->{cust_num} = '987';

# AAAN - ACCH strange customer number 3
$thing->{job_data}->{1}->{cust_num} = 'acch_987x654_321';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'acch-01-02-03_987x654_321.pdf',       'generate AAAN - ACCH strange customer number 3 file name' );
$thing->{job_data}->{1}->{cust_num} = '987';

# AAAN - ACCR
$thing->{job_data}->{1}->{jcode} = 'accr';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'accr-01-02-03_987.pdf',               'generate AAAN - ACCR file name' );

# AAAN - AJPT
$thing->{job_data}->{1}->{jcode} = 'ajpt';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'ajpt-01-02-03_987.pdf',               'generate AAAN - AJPT file name' );

# AAAN - APIN
$thing->{job_data}->{1}->{jcode} = 'apin';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'apin-01-02-03_987.pdf',               'generate AAAN - APIN file name' );

# AAAN - ATAX
$thing->{job_data}->{1}->{jcode} = 'atax';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'atax-01-02-03_987.pdf',               'generate AAAN - ATAX file name' );

# AAAN - BRIA
$thing->{job_data}->{1}->{jcode} = 'bria';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'bria-01-02-03_987.pdf',               'generate AAAN - BRIA file name' );

# AAAN - CIIA
$thing->{job_data}->{1}->{jcode} = 'ciia';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'ciia-01-02-03_987.pdf',               'generate AAAN - CIIA file name' );

# AAAN - IACE
$thing->{job_data}->{1}->{jcode} = 'iace';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'iace-01-02-03_987.pdf',               'generate AAAN - IACE file name' );

# AAAN - ISYS
$thing->{job_data}->{1}->{jcode} = 'isys';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'isys-01-02-03_987.pdf',               'generate AAAN - ISYS file name' );

# AAAN - JETA
$thing->{job_data}->{1}->{jcode} = 'jeta';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'jeta-01-02-03_987.pdf',               'generate AAAN - JETA file name' );

# AAAN - JLAR
$thing->{job_data}->{1}->{jcode} = 'jlar';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'jlar-01-02-03_987.pdf',               'generate AAAN - JLAR file name' );

# AAAN - JLTR
$thing->{job_data}->{1}->{jcode} = 'jltr';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'jltr-01-02-03_987.pdf',               'generate AAAN - JLTR file name' );

# AAAN - JMAR
$thing->{job_data}->{1}->{jcode} = 'jmar';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'jmar-01-02-03_987.pdf',               'generate AAAN - JMAR file name' );

# AAAN - OGNA
$thing->{job_data}->{1}->{jcode} = 'ogna';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'ogna-01-02-03_987.pdf',               'generate AAAN - OGNA file name' );

# AAAN - TNAE
$thing->{job_data}->{1}->{jcode} = 'tnae';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'tnae-01-02-03_987.pdf',               'generate AAAN - TNAE file name' );

# AJCS
$thing->{job_data}->{1}->{jcode} = 'ajcs';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'ajcs_01_02_03_schubert.pdf',          'generate AJCS file name' );

# ARVO - IOVS
$thing->{job_data}->{1}->{jcode} = 'iovs';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'iovs-01-02-03_987.pdf',               'generate ARVO - IOVS file name' );

# ARVO - IOVS strange customer number 1
$thing->{job_data}->{1}->{cust_num} = 'iovs-987';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'iovs-01-02-03_987.pdf',               'generate ARVO - IOVS strange customer number 1 file name' );
$thing->{job_data}->{1}->{cust_num} = '987';

# ARVO - IOVS strange customer number 2
$thing->{job_data}->{1}->{cust_num} = 'iovs_987';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'iovs-01-02-03_987.pdf',               'generate ARVO - IOVS strange customer number 2 file name' );
$thing->{job_data}->{1}->{cust_num} = '987';

# ARVO - IOVS strange customer number 3
$thing->{job_data}->{1}->{cust_num} = 'iovs_987x654_321';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'iovs-01-02-03_987x654_321.pdf',       'generate ARVO - IOVS strange customer number 3 file name' );
$thing->{job_data}->{1}->{cust_num} = '987';

# ARVO - IOVS strange customer number 4
$thing->{job_data}->{1}->{cust_num} = 'iovs[987[654[321';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'iovs-01-02-03_987-654-321.pdf',       'generate ARVO - IOVS strange customer number 3 file name' );
$thing->{job_data}->{1}->{cust_num} = '987';

# ARVO - JOVI
$thing->{job_data}->{1}->{jcode} = 'iovs';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'iovs-01-02-03_987.pdf',               'generate ARVO - IOVS file name' );

# ARVO - TVST
$thing->{job_data}->{1}->{jcode} = 'iovs';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'iovs-01-02-03_987.pdf',               'generate ARVO - IOVS file name' );

# BIRE
$thing->{job_data}->{1}->{jcode} = 'bire';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'bor_01_02_03_987.pdf',                'generate BIRE file name' );

# BIRE strange customer number
$thing->{job_data}->{1}->{cust_num} = 'biolreprod/2014/987';
$thing->{job_data}->{1}->{jcode} = 'bire';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'bor_01_02_03_987.pdf',                'generate BIRE strange customer number file name' );
$thing->{job_data}->{1}->{output_filename} = '987';

# CCAB
$thing->{job_data}->{1}->{jcode} = 'ccab';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'ccab-01-02-03_schubert.pdf',          'generate CCAB file name' );

# EEGO
$thing->{job_data}->{1}->{jcode} = 'eego';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'eego_01-02-03-schubert.pdf',          'generate EEGO file name' );

# EXBM
$thing->{job_data}->{1}->{jcode} = 'exbm';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'exbm-01-02-03.pdf',                   'generate EXBM file name' );

# HEPR
$thing->{job_data}->{1}->{jcode} = 'hepr';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'ajhp-01-02-03.pdf',                   'generate HEPR file name' );

# MICR
$thing->{job_data}->{1}->{jcode} = 'micr';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'micr_01-02-schu.pdf',                 'generate MICR file name' );

# MLAB
$thing->{job_data}->{1}->{jcode} = 'mlab';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'jmla_01-02-03-schubert.pdf',          'generate MLAB file name' );

# MOBG - MOBT
$thing->{job_data}->{1}->{jcode} = 'mobt';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'mobt_01_02-03_schubert.pdf',          'generate MOBG - MOBT file name' );

# MOBG - NOVO
$thing->{job_data}->{1}->{jcode} = 'novo';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'novo_01_02-03_schubert.pdf',          'generate MOBG - NOVO file name' );

# OCHS
$thing->{job_data}->{1}->{jcode} = 'ochs';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'ochs-01-02-03_schubert.pdf',          'generate OCHS file name' );

# ODNT
$thing->{job_data}->{1}->{jcode} = 'odnt';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq '987-odnt-01-02-03.pdf',               'generate ODNT file name' );

# WAER
$thing->{job_data}->{1}->{jcode} = 'waer';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'waer_01_987_03.pdf',                  'generate WAER file name' );

# WAER strange customer number
$thing->{job_data}->{1}->{cust_num} = '987-654.321';
$thing->_cleanup_triggers;
$thing->_determine_output_file_names;
ok( $thing->{job_data}->{1}->{output_filename} eq 'waer_01_987654321_03.pdf',            'generate WAER file name' );
$thing->{job_data}->{1}->{cust_num} = '987';



# fin
done_testing();
