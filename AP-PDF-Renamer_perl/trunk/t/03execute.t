#!/usr/bin/env perl
use strict;
use warnings;

use AP::PDF::Renamer;
use Data::Dumper;                  # for error logs
    $Data::Dumper::Indent = 1;     #     makes dumper cleaner
    $Data::Dumper::Sortkeys = 1;   #     makes dumper cleaner
use File::Copy;
use Test::More;
use Text::Diff;

use_ok('AP::PDF::Renamer');

BEGIN {
    $ENV{locator} = 'locator.dev.allenpress.net';
}

my $file_source_path;
$file_source_path = 't/file_source/';
my $file_input_path;
$file_input_path = 't/file_in/';
my $file_output_path;
$file_output_path = 't/file_out/';
my $file_sent_path;
$file_sent_path = 't/file_sent/';
my $trigger_source_path;
$trigger_source_path = 't/trigger_source/';
my $trigger_input_path;
$trigger_input_path = 't/trigger_in/';
my $trigger_output_path;
$trigger_output_path = 't/trigger_out/';
my @pdf_files;
my @trigger_files;

# Instantiate
my $thing = AP::PDF::Renamer->new(
            locator => {
                        app_name => 'AP::PDF::Renamer',
                        key => 'slitebresi' 
                    },
            logger => {
                        level       => 'trace',
                        destination => { off => 1 },
                        #destination => { logfile => 't/logs/test_03.log' },
                    }
);

# move test sources to working area
    opendir(DIRHANDLE, $file_source_path || die "cannot find \$file_source_path: \'$file_source_path\' to open. $!");
        @pdf_files = readdir(DIRHANDLE);
        @pdf_files = grep{/\.pdf$/xmsi} @pdf_files; # only the PDFs
    closedir(DIRHANDLE);
    foreach my $pdf_file ( @pdf_files ){
        copy($file_source_path.$pdf_file,$file_input_path.$pdf_file)
    }
    undef(@pdf_files);

    opendir(DIRHANDLE, $trigger_source_path || die "cannot find \$trigger_source_path: \'$trigger_source_path\' to open. $!");
        @trigger_files = readdir(DIRHANDLE);
        @trigger_files = grep{/\.tsv$/xmsi} @trigger_files; # only the TSVs
    closedir(DIRHANDLE);
    foreach my $trigger_file ( @trigger_files ){
        copy($trigger_source_path.$trigger_file,$trigger_input_path.$trigger_file)
    }
    undef(@trigger_files);

# scoop up all the triggers and work on them
    my $test = $thing->execute('test');
    ok( $test eq 'true',"execute() returned \$test: \'$test\'." ); # should change this to is()

# done
    done_testing();

# delete all test outputs
    opendir(DIRHANDLE, $file_output_path || die "cannot find \$file_output_path: \'$file_output_path\' to open. $!");
        @pdf_files = readdir(DIRHANDLE);
        @pdf_files = grep{/\.pdf$/xmsi} @pdf_files; # only the PDFs
        @pdf_files = grep{s/^(.+)$/$file_output_path$1/xmsi} @pdf_files; # add file path to file name
    closedir(DIRHANDLE);
    unlink @pdf_files; # delete all the files
    undef(@pdf_files); # clear the array

    opendir(DIRHANDLE, $file_sent_path || die "cannot find \$file_sent_path: \'$file_sent_path\' to open. $!");
        @pdf_files = readdir(DIRHANDLE);
        @pdf_files = grep{/\.pdf$/xmsi} @pdf_files; # only the PDFs
        @pdf_files = grep{s/^(.+)$/$file_sent_path$1/xmsi} @pdf_files; # add file path to file name
    closedir(DIRHANDLE);
    unlink(@pdf_files); # delete all the files
    undef(@pdf_files); # clear the array

    opendir(DIRHANDLE, $trigger_output_path || die "cannot find \$trigger_output_path: \'$trigger_output_path\' to open. $!");
        @trigger_files = readdir(DIRHANDLE);
        @trigger_files = grep{/\.tsv$/xmsi} @trigger_files; # only the TSVs
        @trigger_files = grep{s/^(.+)$/$trigger_output_path$1/xmsi} @trigger_files; # add file path to file name
    closedir(DIRHANDLE);
    unlink(@trigger_files); # delete all the files
    undef(@trigger_files); # clear the array
