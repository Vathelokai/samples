package AP::PDF::Renamer;

use strict;
use warnings;

our $VERSION = '0.1.3';

use Moose;
#has 'run_mode' => (is => 'rw', isa => 'str', lazy => 1, default => 'live');
#has 'success' => (is => 'rw');

use Try::Tiny;                     # for try()catch();
use English qw( -no_match_vars );  # for punctuation variables
use Carp;                          # for carp and croak
use File::Copy;                    # for move and copy
use File::Slurp;                   # for read_file
use DateTime;                      # for date stamps
use Data::Dumper;                  # for error logs
    $Data::Dumper::Indent = 1;     #     makes dump cleaner
    $Data::Dumper::Sortkeys = 1;   #     makes dump cleaner
use MIME::Lite;                    # for sending mail with attachments
use feature 'switch';              # for 'for( when{} )' type switching
with 'AP::Logger::Role';           # for logging
with 'AP::Locatorable';            # for locator app parameters

sub execute {
    my $self        = shift;
    my $run_mode    = shift; # optional param

    my $EMPTY_STRING = q{};

    $self->{_logger}->{destinations}->{string} = 1; # in case we need to read out own logs later.
    $self->{success} = 'true'; # so far

    $self->info('##############################################################################');
    $self->info('Starting AP::PDF::Renamer execute()');

    # check input for validity
    if ( !($run_mode) || $run_mode eq $EMPTY_STRING ){$run_mode = 'live'}; # empty means live
    $run_mode = lc $run_mode;
    $run_mode =~ s{^\s*(.+)\s*$}{$1}xmsig; #trim white space
    if ( $run_mode ne 'live' and $run_mode ne 'test' and $run_mode ne 'debug' ){
        $self->trace("AP::PDF::Renamer.pm execute() failed.  Bad parameter \$run_mode = \'$run_mode\'");
        $self->{success} = 'false';
        $self->_error_handler();
        return $self->{success};
    };
    $self->{run_mode} = $run_mode;

    # loads default file paths
    $self->_get_paths();
    if ( $self->{success} eq 'false' ){
        $self->trace("\t_get_paths() returned \'false\'.  Calling _error_handler().");
        $self->_error_handler();
        $self->info('Ending AP::PDF::Renamer execute() after _get_paths() failure.');
        return $self->{success}
    };

    # reads in trigger files
    $self->_import_triggers();
    if ( $self->{success} eq 'false' ){
        $self->trace("\t_import_triggers() returned \'false\'.  Calling _error_handler().");
        $self->_error_handler();
        $self->info('Ending AP::PDF::Renamer execute() after _import_triggers() failure.');
        return $self->{success}
    };
    if ( $self->{trigger_count} == 0){
        $self->trace("\t_import_triggers() found no trigger files.  Exiting.");
        $self->info('Ending AP::PDF::Renamer execute() after _import_triggers() failure.');
        return $self->{success};
    }

    # cleans up the job data
    $self->_cleanup_triggers();
    if ( $self->{success} eq 'false' ){
        $self->trace("\t_cleanup_triggers() returned \'false\'.  Calling _error_handler().");
        $self->_error_handler();
        $self->info('Ending AP::PDF::Renamer execute() after _cleanup_triggers() failure.');
        return $self->{success}
    };

    # build file paths
    $self->_determine_file_paths();
    if ( $self->{success} eq 'false' ){
        $self->trace("\t_determine_file_paths() returned \'false\'.  Calling _error_handler().");
        $self->_error_handler();
        $self->info('Ending AP::PDF::Renamer execute() after _determine_file_paths() failure.');
        return $self->{success}
    };

    # determine input file names
    $self->_determine_input_file_names();
    if ( $self->{success} eq 'false' ){
        $self->trace("\t_determine_input_file_names() returned \'false\'.  Calling _error_handler().");
        $self->_error_handler();
        $self->info('Ending AP::PDF::Renamer execute() after _determine_input_file_names() failure.');
        return $self->{success}
    };

    # build output file names
    $self->_determine_output_file_names();
    if ( $self->{success} eq 'false' ){
        $self->trace("\t_determine_output_file_names() returned \'false\'.  Calling _error_handler().");
        $self->_error_handler();
        $self->info('Ending AP::PDF::Renamer execute() after _determine_output_file_names() failure.');
        return $self->{success}
    };

    # makes copies with new name
    $self->_deliver_renamed_file();
    if ( $self->{success} eq 'false' ){
        $self->trace("\t_deliver_renamed_file() returned \'false\'.  Calling _error_handler().");
        $self->_error_handler();
        $self->info('Ending AP::PDF::Renamer execute() after _deliver_renamed_file() failure.');
        return $self->{success}
    };

    # clean up files, write logs
    $self->_clean_up();
    if ( $self->{success} eq 'false' ){
        $self->trace("\t_clean_up() returned \'false\'.  Calling _error_handler().");
        $self->_error_handler();
        $self->info('Ending AP::PDF::Renamer execute() after _clean_up() failure.');
        return $self->{success}
    };

    # maintain log files
    $self->_prune_logs();

    # shut it down
    $self->info('Ending AP::PDF::Renamer execute()');

    # if debug mode, dump a log file on the way out
    if ( $self->{run_mode} eq 'debug' ){
        $self->_debug_handler;
    }

    return $self->{success};

}

sub _get_paths{
    # this method will add default file paths to $self
    my $self        = shift;

    my $HYPHEN       = q{-};
    my $EMPTY_STRING = q{};
    my $date         = DateTime->now;
    my $date_ymd     = $date->ymd($HYPHEN);
    my $date_hms     = $date->hms($HYPHEN);

    $self->debug("\tStarting AP::PDF::Renamer _get_paths()");

    # load paths to $self.
    my $settings = $self->_locator->get_settings_hashref;
    try{
        if ( $self->{run_mode} eq 'test' ){
            $self->{path} = {
                input_folder =>       't/file_in/',
                output_folder =>      't/file_out/',
                trigger_in_folder =>  't/trigger_in/',
                trigger_out_folder => 't/trigger_out/',
                activity_log =>       't/logs/activity_'.$date_ymd.'.log',
                error_log =>          't/logs/error_'.$date_ymd.'_'.$date_hms.'.log',
            };
        }else{
            $self->{path} = {
                #input_folder =>       't/file_in/', # job specific.  need to find this for each file,  will actually look like $self->{job_data}->{$counter}->{input_folder}
                #output_folder_sent => 't/file_out/',# job specific.  need to find this for each file,  will actually look like $self->{job_data}->{$counter}->{output_folder_sent}
                output_folder =>       $settings->{file_out_path},
                trigger_in_folder =>   $settings->{trigger_in_path},
                trigger_out_folder =>  $settings->{trigger_out_path},
                activity_log =>        $settings->{log_path} . 'activity_'.$date_ymd.'.log',
                error_log =>           $settings->{log_path} . 'errors_'.$date_ymd.'_'.$date_hms.'.log',
            };
        }
        $self->trace("\t\tSetting \$self->{path}->{output_folder} == \'$self->{path}->{output_folder}\'");
        $self->trace("\t\tSetting \$self->{path}->{trigger_in_folder} == \'$self->{path}->{trigger_in_folder}\'");
        $self->trace("\t\tSetting \$self->{path}->{trigger_out_folder} == \'$self->{path}->{trigger_out_folder}\'");
        $self->trace("\t\tSetting \$self->{path}->{activity_log} == \'$self->{path}->{activity_log}\'");
        $self->trace("\t\tSetting \$self->{path}->{error_log} == \'$self->{path}->{error_log}\'");
    }catch{
        $self->fatal("\t\tAP::PDF::Renamer.pm _get_paths() failed to load paths to \$self.  Aborting");
        $self->debug("\tEnding AP::PDF::Renamer _get_paths()");
        $self->{success} = 'false';
        return;
    };

    # test that paths are valid.
    while ( my $key = each %{$self->{path}} ) {
        if ( $self->{path}->{$key} eq $EMPTY_STRING){
            # empty string is ok
        }elsif ( $self->{path}->{$key} eq $self->{path}->{activity_log} || $self->{path}->{$key} eq $self->{path}->{error_log} ){
            # logs don't exist yet
        }elsif ( -e $self->{path}->{$key} ){ # if the path exists...
            $self->trace("\t\tValid file path:   \$self->{path}->{$key}: \'$self->{path}->{$key}\'");
        }else{
            $self->fatal("\t\tInvalid file path: \$self->{path}->{$key}: \'$self->{path}->{$key}\'. Aborting.");
            $self->{success} = 'false';
        }
    }
    if ( $self->{success} eq 'false' ){
        $self->fatal("\tEnding AP::PDF::Renamer _get_paths().  Invalid paths found. Aborting.");
        return;
    }

    # end normally
    $self->debug("\tEnding AP::PDF::Renamer _get_paths()");

    return;

}

sub _import_triggers{
    # this method will read in the tsv files and add them to $self
    my $self        = shift;

    my $PERIOD     = q{.};
    my $HYPHEN     = q{-};
    my $UNDERSCORE = q{_};
    my $ASTERISK   = q{*};
    my $SLASH      = q{/};

    my @trigger_files;

    $self->debug("\tStarting AP::PDF::Renamer _import_triggers()");

    # get list of files from folder
    try{
        opendir my $dir_handle, $self->{path}->{trigger_in_folder};
        @trigger_files = readdir $dir_handle;
        @trigger_files = grep{/[.]tsv/xmsi} @trigger_files; # only keep the TSV files
        closedir $dir_handle;
    }catch{
        $self->fatal("\t\tCould not open \$self->{path}->{trigger_in_folder}: \'$self->{path}->{trigger_in_folder}\'. Aborting AP::PDF::Renamer _import_triggers().");
        $self->{success} = 'false';
    };

    # check for empty array
    $self->{trigger_count} = @trigger_files;
    if ( $self->{trigger_count} == 0 ){
        $self->debug("\t\tEnding AP::PDF::Renamer _import_triggers().  No triggers found.");
        return;
    }

    #ingest each line of each file
    my $counter = 0;
    foreach my $trigger_file ( @trigger_files ){
        $counter++;
        $self->trace("\t\tReading \$trigger_file $counter: \'$trigger_file\'");

        # read in the file
        my $line = read_file( $self->{path}->{trigger_in_folder}.$trigger_file );
        $line =~ s{\n}{}xmsig; # sometimes linebreaks are copied into paradox and exported with the trigger file
        chomp $line;
        $self->trace("\t\t\t\$line: \'$line\'");

        # read contents into hash
        # perlcritic doesn't like numbers greater than 2, but too bad
        my @values = split /\t/xms,$line; #tab delimited
        $self->{job_data}->{$counter} = {
            jcode        => $values[0],
            vol          => $values[1],
            iss          => $values[2],
            month        => $values[3],
            special      => $values[4],
            ap_num       => $values[5],
            cust_num     => $values[6],
            authors      => $values[7],
            cor_author   => $values[8],
            beg_pg       => $values[9],
            end_pg       => $values[10],
            cycle        => $values[11],
        };
    } # end foreach  @trigger_files

    $self->debug("\tEnding AP::PDF::Renamer _import_triggers()");

    return;

}

# should split this lower part into it's own method

sub _cleanup_triggers{
    # this method will read in the tsv files and add them to $self
    # then it clears out the old tsv files
    my $self         = shift;
    my $PERIOD       = q{.};
    my $HYPHEN       = q{-};
    my $UNDERSCORE   = q{_};
    my $ASTERISK     = q{*};
    my $SLASH        = q{/};
    my $EMPTY_STRING = q{};

    while ( my $counter = each %{$self->{job_data}} ) {

        my $this_job = $self->{job_data}->{$counter};

        $this_job->{jcode} = lc($this_job->{jcode});
        $this_job->{first_letter} = lc(substr $this_job->{jcode}, 0, 1); # snag first character
        $this_job->{file_type}    = 'pdf'; # current default

        # generate alternate jcodes
        $this_job->{alt_jcode} = $this_job->{jcode}; # set the default
        if ( $this_job->{jcode} eq 'bire' ){ $this_job->{alt_jcode} = 'bor' }
        if ( $this_job->{jcode} eq 'hepr' ){ $this_job->{alt_jcode} = 'ajhp' }
        if ( $this_job->{jcode} eq 'mlab' ){ $this_job->{alt_jcode} = 'jmla' }

        # clean up article author
        $this_job->{authors} =~ s{[ ]*et[ ]al[.]?[ ]*}{}xmsig;
        $this_job->{authors} =~ s{[&]}{and}xmsig;
        $this_job->{authors} =~ s{^[ ]+}{}xmsig; # psuedo chomp
        $this_job->{authors} =~ s{[ ]+$}{}xmsig; # psuedo chomp

        # get first author name
        $this_job->{authors_first} = $this_job->{authors};
        $this_job->{authors_first} =~ s{^([^, ]+?)([, ].*)$}{$1}xmsig;

        # clean up corresponding author
        if ( $this_job->{cor_author} eq 'no_cor_author' ){
            $this_job->{cor_author} = $this_job->{authors_first};
        }
        $this_job->{cor_author} =~ s{[ ]*et[ ]al[.]?[ ]*}{}xmsig;
        $this_job->{cor_author} =~ s{[&]}{and}xmsig;
        $this_job->{cor_author} =~ s{^[ ]+}{}xmsig; # psuedo chomp
        $this_job->{cor_author} =~ s{[ ]+$}{}xmsig; # psuedo chomp
        $this_job->{cor_author} =~ s{^.*[[:^alpha:]]([[:alpha:]]+)$}{$1}xmsi;
        $this_job->{cor_author_trunc} = substr $this_job->{cor_author}, 0, 4; # first 4 characters

        # clean up page ranges
        $this_job->{beg_pg} =~ s{no_beg_pg}{0}xmsi;
        $this_job->{end_pg} =~ s{no_end_pg}{0}xmsi;

        # build trimmed volume and issue
        $this_job->{vol_trimmed}  = $this_job->{vol};
        $this_job->{iss_trimmed}  = $this_job->{iss};
        while ($this_job->{vol_trimmed} ne '0' && substr($this_job->{vol_trimmed},0,1) eq '0' ){ # while the first number is zero
            $this_job->{vol_trimmed} =~ s{^.(.+)$}{$1}xmsig;  # drop the first number
        }
        while ($this_job->{iss_trimmed} ne '0' && substr($this_job->{iss_trimmed},0,1) eq '0' ){ # while the first number is zero
            $this_job->{iss_trimmed} =~ s{^.(.+)$}{$1}xmsig;  # drop the first number
        }

        # build padded volume and issue
        $this_job->{vol_padded}   = $this_job->{vol_trimmed};
        $this_job->{iss_padded}   = $this_job->{iss_trimmed};
        if (length($this_job->{vol_padded}) < 2){
            $this_job->{vol_padded} = '0'.$this_job->{vol_padded};
        }
        if (length($this_job->{iss_padded}) < 2){
            $this_job->{iss_padded} = '0'.$this_job->{iss_padded};
        }

        # cleanup cust_num: no_cust_num
        # customer number cleanup is specific per customer, so most of it happens in _determine_output_file_name
        if ( $this_job->{cust_num} eq 'no_cust_num' ){
            $this_job->{cust_num} = 'no_cust_num_found';
        }

        # report it
        $self->trace("\t\tSaved hash results:");
        while ( my $key = each %{$this_job} ) {
            $self->trace("\t\t\t\$this_job->{$key} == \'$this_job->{$key}\'");
        }

        # test some things
        if ( $this_job->{first_letter} !~ m{[[:lower:]]}xmsi ){
                $self->fatal("\t\t\tInvalid \$this_job->{first_letter}: \'$this_job->{first_letter}\'. Aborting");
                $self->{success} = 'false';
        }

    } # end while each job_data

    if ( $self->{success} eq 'false' ){
        $self->fatal("\tEnding AP::PDF::Renamer _get_paths().  Invalid paths found. Aborting.");
        return;
    }

    $self->debug("\tEnding AP::PDF::Renamer _cleanup_triggers()");

    return;

}

sub _determine_file_paths{
    # this method determines xinet file path based on the trigger data
    my $self        = shift;

    my $PERIOD     = q{.};
    my $HYPHEN     = q{-};
    my $UNDERSCORE = q{_};
    my $ASTERISK   = q{*};
    my $SLASH      = q{/};

    $self->debug("\tStarting AP::PDF::Renamer _determine_file_paths()");

    while ( my $counter = each %{$self->{job_data}} ) {

        my $this_job = $self->{job_data}->{$counter};

        # determine where to pick files up from
        my $settings = $self->_locator->get_settings_hashref;

        $this_job->{input_folder} =
            $settings->{file_source_base_path}.$SLASH.
            $this_job->{first_letter}.$SLASH.
            $this_job->{jcode}.$SLASH.'live_jobs'.$SLASH.
            $this_job->{jcode}.$HYPHEN.
            $this_job->{vol_padded}.$HYPHEN.
            $this_job->{iss_padded}.$SLASH.'_proofs'.$SLASH;

        if( $this_job->{cycle} eq '1xo' ){
            $this_job->{input_folder} = $this_job->{input_folder}.'first/';
        }
        elsif( $this_job->{cycle} eq 'revision' ){
            $this_job->{input_folder} = $this_job->{input_folder}.'revisions/';
        }else{
            $self->fatal("\t\t\tUnable to determine input folder from \$this_job->{cycle}: \'$this_job->{cycle}\'. Aborting");
            $self->{success} = 'false';
        }

        # get sent folder for the pdfs to move to
        $this_job->{output_folder_sent} = $this_job->{input_folder}.'_sent/';

        # switch paths back if this is test mode
        if ( $self->{run_mode} eq 'test' ){
            $self->trace("\t\t\tChanging file paths back to test mode paths.");
            $this_job->{output_folder_sent} = 't/file_sent/';
            $this_job->{input_folder} = 't/file_in/';
            $self->trace("\t\t\t\t\$this_job->{input_folder} == \'$this_job->{input_folder}\'");
            $self->trace("\t\t\t\t\$this_job->{output_folder_sent} == \'$this_job->{output_folder_sent}\'");
        }

        # make sure file paths are valid
        if ( -e $this_job->{input_folder} ){ # if the path exists...
            $self->trace("\t\tValid file path:   \$this_job->{input_folder}: \'$this_job->{input_folder}\'");
        }else{
            $self->fatal("\t\tInalid file path:  \$this_job->{input_folder}: \'$this_job->{input_folder}\'. Aborting");
            $self->{success} = 'false';
        }
        if ( -e $this_job->{output_folder_sent} ){ # if the path exists...
            $self->trace("\t\tValid file path:   \$this_job->{output_folder_sent}: \'$this_job->{output_folder_sent}\'");
        }else{
            $self->fatal("\t\tInalid file path:  \$this_job->{output_folder_sent}: \'$this_job->{output_folder_sent}\'. Aborting");
            $self->{success} = 'false';
        }

    } # end while each job_data

    if ( $self->{success} eq 'false' ){
        $self->fatal("\tEnding AP::PDF::Renamer _determine_file_paths().  Invalid paths found. Aborting.");
        return;
    }

    $self->debug("\tEnding AP::PDF::Renamer _determine_file_paths()");

    return;

}

sub _determine_input_file_names{
    # this method will check the imput folder and get the real file name
    my $self       = shift;

    my $PERIOD     = q{.};
    my $HYPHEN     = q{-};
    my $ASTERISK   = q{*};

    $self->debug("\tStarting AP::PDF::Renamer _determine_input_file_names()");

    # for each imported job trigger
    while ( my $counter = each %{$self->{job_data}} ) {

        my $this_job = $self->{job_data}->{$counter};

        # get search string for the incoming file name, with a wildcard asterisk
        $this_job->{input_filename_search} =
            lc(
                $this_job->{jcode}.$HYPHEN.
                $this_job->{vol_padded}.$HYPHEN.
                $this_job->{iss_padded}.$HYPHEN.
                $this_job->{ap_num}.$ASTERISK.
                $PERIOD.$this_job->{file_type}
            );
        $self->trace("\t\t\tDetermined \$this_job->{input_filename_search} == \'$this_job->{input_filename_search}\'.");

        # get the literal files name from the server.
        # glob gets all filenames that match the pattern above.
        my $file_search = $this_job->{input_folder}.$this_job->{input_filename_search};
        my @file_list = glob $file_search;

        if (! @file_list){
            $self->{success} = 'false';
            $self->fatal("\t\t\tNo file list found via \'glob($file_search)\'.  Aborting.");
            $self->fatal("\t\t\tFolder only contained the following:");
            my @all_files = glob($this_job->{input_folder});
            foreach my $file (@all_files){
                $self->fatal("\t\t\t\t$file");
            }
        }

        # assuming only one file in xinet for each trigger file
        #remove the path from the file name and add to $self
        $file_list[0] =~ s{^.+([\/\\])([^\1]+)$}{$2}xmsi;
        $this_job->{input_filename} = $file_list[0];
        $self->trace("\t\t\tDetermined \$this_job->{input_filename} == \'$this_job->{input_filename}\'.");

    } # end while ( my ($counter) = each(%{ $self->{job_data} }) )

    if ( $self->{success} eq 'false' ){
        $self->fatal("\tEnding AP::PDF::Renamer _determine_input_file_names().  Aborting.");
        return;
    }else{
        $self->debug("\tEnding AP::PDF::Renamer _determine_input_file_names()");
        return;
    }

}

sub _determine_output_file_names{
    # this method will invent the output file name
    my $self          = shift;

    my $PERIOD        = q{.};
    my $HYPHEN        = q{-};
    my $UNDERSCORE    = q{_};
    my $ASTERISK      = q{*};
    my $SLASH         = q{/};
    my $arvo_journals = '(?:iovs|jovi|tvst)';
    my $aaan_journals = '(?:acch|accr|ajpt|apin|atax|bria|ciia|iace|isys|jeta|jlar|jltr|jmar|ogna|tnae)';
    my $mobg_journals = '(?:mobt|novo)';

    $self->debug("\tStarting AP::PDF::Renamer _determine_output_file_names()");

    # for each imported job trigger
    while ( my $counter = each %{$self->{job_data}} ) {

        my $this_job = $self->{job_data}->{$counter};

        # giant switch case block
        # societies are listed before journals
        # journals are alphabetized
        for($this_job->{jcode}){

            when( /(?:$arvo_journals)/xmsi ){
                 $this_job->{cust_num} =~ s{^[[:alpha:]]+[-_\[\]](.+)$}{$1}xmsi;
                 $this_job->{cust_num} =~ s{[\[\]]}{-}xmsig;
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$HYPHEN.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{ap_num}.$UNDERSCORE.
                         $this_job->{cust_num};
            }

            when( /(?:$aaan_journals)/xmsi ){
                 #$this_job->{cust_num} =~ s{^[a-zA-Z]+[-_](.+)$}{$1}xmsi;
                 $this_job->{cust_num} =~ s{^[[:alpha:]]+[-_\[\]](.+)$}{$1}xmsi;
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$HYPHEN.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{ap_num}.$UNDERSCORE.
                         $this_job->{cust_num};
            }

            when( /(?:$mobg_journals)/xmsi ){
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$UNDERSCORE.
                         $this_job->{vol_padded}.$UNDERSCORE.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{ap_num}.$UNDERSCORE.
                         $this_job->{authors_first};
            }

            when('ajcs'){
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$UNDERSCORE.
                         $this_job->{vol_padded}.$UNDERSCORE.
                         $this_job->{iss_padded}.$UNDERSCORE.
                         $this_job->{ap_num}.$UNDERSCORE.
                         $this_job->{authors_first};
            }

            when('bire'){
                $this_job->{cust_num} =~ s{^.+\/([^\/]+)$}{$1}xmsi;
                $this_job->{output_filename} =
                        $this_job->{alt_jcode}.$UNDERSCORE.
                        $this_job->{vol_padded}.$UNDERSCORE.
                        $this_job->{iss_padded}.$UNDERSCORE.
                        $this_job->{ap_num}.$UNDERSCORE.
                        $this_job->{cust_num};
            }

            when('ccab'){
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$HYPHEN.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{ap_num}.$UNDERSCORE.
                         $this_job->{authors_first};
            }

            when('dtco'){
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$UNDERSCORE.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{cor_author_trunc};
            }

            when('eego'){
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$UNDERSCORE.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{ap_num}.$HYPHEN.
                         $this_job->{cor_author};
            }

            when('exbm'){
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$HYPHEN.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{ap_num};
            }

            when('hepr'){
                 $this_job->{output_filename} =
                         $this_job->{alt_jcode}.$HYPHEN.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{ap_num};
            }

            when('micr'){
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$UNDERSCORE.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{cor_author_trunc};
            }

            when('mlab'){
                 $this_job->{output_filename} =
                         $this_job->{alt_jcode}.$UNDERSCORE.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{ap_num}.$HYPHEN.
                         $this_job->{authors_first};
            }

            when('ochs'){
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$HYPHEN.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{ap_num}.$UNDERSCORE.
                         $this_job->{authors_first};
            }

            when('odnt'){
                 $this_job->{output_filename} =
                         $this_job->{cust_num}.$HYPHEN.
                         $this_job->{jcode}.$HYPHEN.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{ap_num};
            }

            when('panp'){
                 $this_job->{cust_num} =~ s{[_ .]}{-}xmsg;
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$HYPHEN.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{ap_num}.$HYPHEN.
                         $this_job->{cust_num};
            }

            when('rsoc'){
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$HYPHEN.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{ap_num}.$UNDERSCORE.
                         $this_job->{cor_author};
            }

            when('vclp'){
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$HYPHEN.
                         $this_job->{vol_padded}.$HYPHEN.
                         $this_job->{iss_padded}.$HYPHEN.
                         $this_job->{authors};
            }

            when('waer'){
                 $this_job->{cust_num} =~ s{[-_ .]}{}xmsg;
                 $this_job->{output_filename} =
                         $this_job->{jcode}.$UNDERSCORE.
                         $this_job->{vol_padded}.$UNDERSCORE.
                         $this_job->{cust_num}.$UNDERSCORE.
                         $this_job->{ap_num};
            }

            default {
                $this_job->{output_filename} =
                        $this_job->{jcode}.$UNDERSCORE.
                        $this_job->{vol_padded}.$UNDERSCORE.
                        $this_job->{iss_padded}.$HYPHEN.
                        $this_job->{ap_num}.$UNDERSCORE.
                        $this_job->{beg_pg}.$UNDERSCORE.
                        $this_job->{end_pg};
            }

        } # end of for($this_job->{jcode}) switch case block

        # finish for all file names
        $this_job->{output_filename} = $this_job->{output_filename}.$PERIOD.$this_job->{file_type};
        $this_job->{output_filename} = lc($this_job->{output_filename});

        # revision suffixes not yet enabled.
        #$this_job->{output_filename} =~ s{_1r\.pdf}{_1R.pdf}xmsi; # the revision note should be uppercase
        #$this_job->{output_filename} =~ s{_1rev\.pdf}{_1REV.pdf}xmsi; # the revision note should be uppercase

        # cleanup for characters prevented in windows file paths
        $this_job->{output_filename} =~ s{([^a-zA-Z0-9_.-])}{_}xmsig;
        $this_job->{output_filename} =~ s{[_]+}{_}xmsig;

        # report it
        $self->trace("\t\t\tDetermined \$this_job->{output_filename} == \'$this_job->{output_filename}\'.");

    } # end while ( my ($counter) = each(%{ $self->{job_data} }) )

    if ( $self->{success} eq 'false' ){
        $self->fatal("\tEnding AP::PDF::Renamer _determine_output_file_names().  Aborting.");
        return;
    }else{
        $self->debug("\tEnding AP::PDF::Renamer _determine_output_file_names()");
        return;
    }

}

sub _deliver_renamed_file{
    # this method will use the paths and names in $self to deliver
    #     a copy with the correct name
    my $self        = shift;

    $self->debug("\tStarting AP::PDF::Renamer _deliver_renamed_file()");

    while ( my $counter = each %{$self->{job_data}} ) {

        my $this_job = $self->{job_data}->{$counter};

        # set up file paths
        my $input_file = $this_job->{input_folder}.$this_job->{input_filename};
        $self->trace("\t\t\tSetting \$input_file: \'$input_file\'.");
        my $output_file = $self->{path}->{output_folder}.$this_job->{output_filename};
        $self->trace("\t\t\tSetting \$output_file: \'$output_file\'.");
        my $output_file_sent = $this_job->{output_folder_sent}.$this_job->{input_filename};
        $self->trace("\t\t\tSetting \$output_file_sent: \'$output_file_sent\'.");

        # ensure input files can be found
        if ( ! -e $input_file ){
            $self->fatal("\t\tUnable to find \$input_file: \'$input_file\'. Aborting.");
            $self->{success} = 'false';
            next;
        }

        # quick bug fix
        # perl 5.10 seems to have a problem with periods in file names for the output of copy() and move().
        # input file is ok to have periods though
        # so, we are temporarily replacing those with underscores
        $output_file =~ s{(\d)(?:[.])+(\d)}{$1_$2}xmsig;
        $output_file_sent =~ s{(\d)(?:[.])+(\d)}{$1_$2}xmsig;

        # copy pdf from xinet to workspace with the new pdf file name
        try{
            copy($input_file,$output_file_sent) or croak "Copy failed: $ERRNO";
            $self->debug("\t\tCopied file \$input_file: \'$input_file\' to \$output_file_sent: \'$output_file_sent\'.");
        }catch{
            $self->fatal("\t\tCould not copy file \$input_file: \'$input_file\' to \$output_file_sent: \'$output_file_sent\'.");
            $self->{success} = 'false';
        };

        # move pdf from xinet to xinet/_sent folder with the old pdf file name
        try{
            move($input_file,$output_file) or croak "Move failed: $ERRNO";
            $self->debug("\t\tMoved file \$input_file: \'$input_file\' to \$output_file: \'$output_file\'.");
        }catch{
            $self->fatal("\t\tCould not move file \$input_file: \'$input_file\' to \$output_file: \'$output_file\'.");
            $self->{success} = 'false';
        };
    }

    if ( $self->{success} eq 'false' ){
        $self->fatal("\tEnding AP::PDF::Renamer _determine_output_file_names().  Unable to move or copy files. Aborting.");
        return;
    }else{
        $self->debug("\tEnding AP::PDF::Renamer _deliver_renamed_file()");
        return;
    }

}

sub _clean_up{
    # this method will clean up anything left and
    #     write log files
    my $self         = shift;

    my $EMPTY_STRING = q{};
    my $HYPHEN       = q{-};

    my @trigger_files;

    my $return_value; # catch returns from functions

    $self->debug("\tStarting AP::PDF::Renamer _clean_up()");

    # move trigger from in to out folder
    try{
        $return_value = opendir my $dir_handle, $self->{path}->{trigger_in_folder}; # || croak "cannot find \$self->{path}->{trigger_in_folder}: \'$self->{path}->{trigger_in_folder}\' to open.");
        @trigger_files = readdir $dir_handle;
        @trigger_files = grep{/[.]tsv/xmsi} @trigger_files; # only the TSVs
        $return_value = closedir $dir_handle;
        foreach my $trigger_file ( @trigger_files ){
            move($self->{path}->{trigger_in_folder}.$trigger_file,$self->{path}->{trigger_out_folder}.$trigger_file)
        }
    }catch{
        $self->{success} = 'false';
        $self->fatal("\tEnding AP::PDF::Renamer _clean_up(). Cannot find \$self->{path}->{trigger_in_folder}: \'$self->{path}->{trigger_in_folder}\' to open. Aborting.");
    };

    my $activity_report;
    while ( my $counter = each %{$self->{job_data}} ) {
        my $this_job = $self->{job_data}->{$counter};
        $activity_report = "\n".DateTime->now.' - Job: '.$this_job->{jcode}.$HYPHEN.$this_job->{vol}.$HYPHEN.$this_job->{iss}.$HYPHEN.$this_job->{ap_num}."\n".
                           "\tMoved \'".$this_job->{input_folder}.$this_job->{input_filename}."\' \n".
                           "\t   to \'".$self->{path}->{output_folder}.$this_job->{output_filename}."\' \n".
                           "\t  and \'".$this_job->{output_folder_sent}.$this_job->{input_filename}."\' \n";

    }
    try{
        $return_value = open my $fh_activity, '>>',$self->{path}->{activity_log};
        $return_value = print {$fh_activity} $activity_report;
        $return_value = close $fh_activity;
    }catch{
        $self->{success} = 'false';
        $self->fatal("\tEnding AP::PDF::Renamer _clean_up().  Unable to write to activity log. Aborting.");
    };

    if ( $self->{success} eq 'false' ){
        $self->fatal("\tEnding AP::PDF::Renamer _clean_up().  Unable to clean up. Aborting.");
        return;
    }else{
        $self->debug("\tEnding AP::PDF::Renamer _clean_up()");
        return;
    }

}

sub _prune_logs{
    my $self               = shift;

    my $log_retention_days = 30;
    my $HYPHEN             = q{-};

    my $return_value; # catch returns from functions

    $self->debug("\tStarting AP::PDF::Renamer _prune_logs()");

    # get settings from locator
    my $settings = $self->_locator->get_settings_hashref;

    # get the file names for all the logs
    my @log_list = glob($settings->{log_path}.'*.log');

    if (! @log_list){
        $self->{success} = 'false';
        $self->fatal("\t\t\tNo file list found via \'glob($settings->{log_path}\'\*\.log\')\'.  Aborting.");
    }

    foreach my $log_file ( @log_list ){
        # get log date
        my $file_name = $log_file;

        # trim label from front of name and file type from end
        $file_name =~ s{^[^/]+[/](.+)}{$1}xmsi;    # drop the file path before the file name
        $file_name =~ s{^[^_]+_(.+)}{$1}xmsi;      # drop everything up to the first underscore
        $file_name =~ s{^(.+)_.+$}{$1}xmsi;        # drop everything after any other underscore
        $file_name =~ s{([^.]+)[.]log$}{$1}xmsi;   # drop file extension

        if ( $file_name !~ m{\d{4}[-]\d{2}[-]\d{2}}xmsi){
            $self->{success} = 'false';
            $self->error("\t\tUnable to parse file name to get date.  \$file_name: \'$file_name\'.");
        }

        my @file_name_components = split $HYPHEN, $file_name;
        my $file_date = DateTime->new( year => $file_name_components[0], month => $file_name_components[1], day => $file_name_components[2] );

        # get the oldest allowed date
        my $cutoff_date = DateTime->now;
        $cutoff_date->subtract( days => $log_retention_days );

        # compare to cut off date
        my $comparison = DateTime->compare( $file_date, $cutoff_date );

        # delete old logs
        if ( $comparison == -1 ){
            unlink $settings->{log_path}.$log_file
        }

        # report it
        my $activity_report;
        $activity_report = DateTime->now." - Pruning log files\n".
                           "\tRemoved  \'".$settings->{log_path}.$log_file."\' \n".
        try{
            $return_value = open my $fh_activity, '>>',$self->{path}->{activity_log};
            $return_value = print {$fh_activity} $activity_report;
            $return_value = close $fh_activity;
        }catch{
            $self->{success} = 'false';
            $self->fatal("\tEnding AP::PDF::Renamer _prune_logs().  Unable to write to activity log. Aborting.");
        };

    }

    if ( $self->{success} eq 'false' ){
        $self->error("\tEnding AP::PDF::Renamer _prune_logs().  Unable to delete old logs.");
    }else{
        $self->debug("\tEnding AP::PDF::Renamer _prune_logs()");
    }

    $self->{success} = 'true'; # not going to kill the whole module because pruning failed

    return;

}

sub _error_handler{
    # this method will deal with errors thrown by other methods
    my $self        = shift;

    my $HYPHEN      = q{-};

    my $return_value; # catch returns from functions

    $self->debug("\tStarting AP::PDF::Renamer _error_handler()");

    $self->{success} = 'true'; # it comes in false, but we want to check for new errors after this point

    # move trigger from in to out folder - if this isn't done, the program keeps trying to use the triggers and sending error mail
    my @trigger_files;
    try{
        $return_value = opendir my $dir_handle, $self->{path}->{trigger_in_folder};  # || croak "cannot find \$self->{path}->{trigger_in_folder}: \'$self->{path}->{trigger_in_folder}\' to open.");
        @trigger_files = readdir $dir_handle;
        @trigger_files = grep{/[.]tsv/xmsi} @trigger_files; # only the TSVs
        $return_value = closedir $dir_handle;
        foreach my $trigger_file ( @trigger_files ){
            move($self->{path}->{trigger_in_folder}.$trigger_file,$self->{path}->{trigger_out_folder}.$trigger_file)
        }
    }catch{
        $self->{success} = 'false';
        $self->fatal("\t\tEnding AP::PDF::Renamer _error_handler().  cannot find \$self->{path}->{trigger_in_folder}: \'$self->{path}->{trigger_in_folder}\' to open. Aborting.");
    };

    # get parameters from the locator app ( http://locator.allenpress.net/applications/36/settings )
    my $settings = $self->_locator->get_settings_hashref;

    # pull the logs out of $self for better formatting
    my $error_log = $self->message_string;
    undef $self->{_logger}->{string};

    my $core_dump = Dumper $self;
    my $error_report = "ERROR LOG #########################################\n\n".
                       $error_log."\n\n".
                       "Core Dump #########################################\n\n".
                       "Below is the entire \$self object from AP::PDF::Renamer.\n\n".
                       $core_dump."\n";

    # write an error log file
    try{
        $return_value = open my $fh_error, '>>', $self->{path}->{error_log};
        $return_value = print {$fh_error} $error_report;
        $return_value = close $fh_error;
        $self->trace("\tWrote error log: \'$self->{path}->{error_log}\'");
    }catch{
        $self->{success} = 'false';
        $self->fatal("\t\tEnding AP::PDF::Renamer _error_handler().  Unable to write to error log. Aborting.");
    };

    # build an email
    my $msg;
    if ( $self->{run_mode} eq 'test' ){
        $msg = MIME::Lite->new(
                Type    => 'multipart/mixed',
                Subject => 'Testing: PDF renamer errors',
                To      => $settings->{error_mail_test},
                From    => $settings->{error_mail_test},
            );
    }else{
        my $subject_line = 'PDF renamer errors: '.
                           $self->{job_data}->{1}->{jcode}.$HYPHEN.
                           $self->{job_data}->{1}->{vol}.$HYPHEN.
                           $self->{job_data}->{1}->{iss}.$HYPHEN.
                           $self->{job_data}->{1}->{ap_num};
        $msg = MIME::Lite->new(
                Type    => 'multipart/mixed',
                Subject => $subject_line,
                To      => $settings->{error_mail},
                From    => $settings->{error_mail},
            );
    }

    # place message text in email
    my $BACK_SLASH = q{\\}; # windows file path slash
    my $network_error_log = $self->{path}->{error_log};
    $network_error_log =~ s{smb_shares}{fv1}xmsi;
    $network_error_log =~ s{\/}{\\}xmsi;
    $network_error_log = $BACK_SLASH.$network_error_log;

    $msg->attach(
        Type     => 'TEXT',
        Data => "The PDF Renamer application on FV1 has failed.\n".
                "A file distribution operator is waiting for this file.\n".
                "Please contact via Instant Message or by phone extension x147.\n".
                "The error log is attached, and is also availiable at\n".
                "\t$network_error_log.\n",
    );

    # attach file to email
    $msg->attach(
        Type     => 'text/plain',
        Path     => "$self->{path}->{error_log}",
        Filename => 'error.log',
        Disposition => 'attachment',
    );

    # send the mail
    try{
        $msg->send('smtp','mail2.allenpress.com');
        $self->trace("\t".'Sent mail to apop-error@allenpress.com');
    }catch{
        $self->{success} = 'false';
        $self->fatal("\t\tEnding AP::PDF::Renamer _error_handler().  Unable to send mail. Aborting.");
    };

    $self->debug("\tEnding AP::PDF::Renamer _error_handler()");

    if ( $self->{success} eq 'false' ){
        $self->fatal("\tEnding AP::PDF::Renamer _error_handler().  Unable to Report errors. Aborting.");
        croak('AP::PDF::Renamer _error_handler() was unable to report the modules errors.  Dying.');
    }else{
        $self->debug("\tEnding AP::PDF::Renamer _error_handler()");
        return;
    }

    return;

}

sub _debug_handler{
    # this method dumps a log file after each run
    my $self        = shift;

    my $return_value; # catch returns from functions

    $self->debug("\tStarting AP::PDF::Renamer _debug_handler()");

    # get parameters from the locator app ( http://locator.allenpress.net/applications/36/settings )
    my $settings = $self->_locator->get_settings_hashref;

    # pull the logs out of $self for better formatting
    my $debug_log = $self->message_string;

    my $core_dump = Dumper $self;
    my $debug_report = "DEBUG LOG #########################################\n\n".
                       $debug_log."\n\n".
                       "Core Dump #########################################\n\n".
                       "Below is the entire \$self object from AP::PDF::Renamer.\n\n".
                       $core_dump."\n";

    my $debug_file_name = $self->{path}->{error_log};
    $debug_file_name =~ s{error}{debug}xmsi;
    #$debug_file_name =~ s{error}{debug}xmsi;

    # write a debug log file
    try{
        $return_value = open my $fh_debug, '>>',$debug_file_name;
        $return_value = print {$fh_debug} $debug_report;
        $return_value = close $fh_debug;
        $self->trace("\tWrote debug log: \'$debug_file_name\'");
    }catch{
        #$self->{success} = 'false';
        $self->fatal("\t\tEnding AP::PDF::Renamer _debug_handler().  Unable to write to debug log. Aborting.");
    };

    $self->debug("\tEnding AP::PDF::Renamer _debug_handler()");

    return;

}

1;

__END__;

=head1 NAME

AP::PDF::Renamer - file delivery tool

=head1 VERSION

Version 0.1.2

=cut

=head1 SYNOPSIS

    use AP::PDF::Renamer;

    my $object = AP::PDF::Renamer->new(
        locator => {
                    app_name => 'AP::PDF::Renamer',
                    key => 'slitebresi'
                },
        logger => {
                    level       => 'trace',
                    destination => { off => 1 },
                    #destination => { logfile => 't/logs/name_of.log' },
                }
    );

    my $return_value = $object->execute();
    #$return_value = $object->execute('test');
    #$return_value = $object->execute('live');
    #$return_value = $object->execute('debug');

    if ( $return_value = 'true'){
        print "Success.\n";
    }else{
        print "Failure.\n";
    };

=head1 DESCRIPTION

    This is a tool to rename pdfs on the file server.
    Currently, this tool lives on FV1 and modifies files on XINET.
    Paradox drops a tsv instruction file, which is read by this module.
    This module finds the listed files on Xinet/production. The file is
        moved to the appropriate _sent folder. A copy with the new name
        is placed in the FV1 server working folder.
    This module is designed to run on the FV1 server.  That server has
        a crontab entry that ensures this module runs continuously. That
        entry triggers a BASH script which monitors the trigger's file
        folder every few seconds.  In the event of failure, the crontab
        restarts the BASH script.
    This module makes extensive use of AP Logger.  When debugging, take
        advantage of the output by changing the destination value.
    As part of normal process, an activity log is generated and maintained
        each day.  The path to the log folder is set in AP Locator.
    As part of normal process, any job that sets $self->{success} == 'false'
        will generate an error log.  The log will be saved in the log
        folder and will also be emailed to the system administrator listed
        in AP Locator.
    Logs older than 30 days are automatically pruned.

=head1 SUBROUTINES/METHODS

=head2 new

    Instantiate an object.
    Requires directions to the AP Locator application.
    Requires basic AP Logger instructions.

=head2 execute

    Read the trigger files and rename the files on the server.
    Will take an optional arguement to set the run level (default 'live').
    The 'test' level uses the /t/ folders on the machine running the module.
    The 'live' level uses local folders on the FV1 server and
        presumes access to the Xinet/production server.
    The 'debug' level runs like 'live', but dumps a log file at the end
        of the run.
    This subroutine calls all the methods and checks $self->{success} to
        determine if a method failed.
    In the event of failure of a method, all other methods are skipped and
        the error handle method is called.
    This subroutine returns $self->{success}, which is a string that
        is either 'true' or 'false'.

=head2  _get_paths

    In 'test' mode, this loads the default file paths at /t/.
    In 'live' mode, this retrieves the file paths from AP Locator.
    All file paths are tested for existance.
    On error, it sets $self->{success} = 'false';
    This method returns nothing.

=head2  _import_triggers

    This method opens the file path for the triggers and reads
        all files with the .tsv file extension.
    Each row of each file is examined. The data is split into
        an array which is loaded to $self->{job_data}->{$counter}
    On error, it sets $self->{success} = 'false';
    This method returns nothing

=head2 _cleanup_triggers

    This method standardizes all trigger data loaded to
        $self->{job_data}->{$counter}.
    Padded and trimmed numbers are generated, alternate jcodes
        are set, placeholders are filled in, etc.
    On error, it sets $self->{success} = 'false';
    This method returns nothing

=head2  _determine_file_paths

    This module builds file paths for Xinet.
    A base file path is retrieved from AP Locator and the rest of
        the file path is built from the info in
        $self->{job_data}->{$counter}.
    The newly generated paths are checked for existance.
    On error, it sets $self->{success} = 'false';
    This method returns nothing

=head2  _determine_input_file_names

    Searches the Xinet folder for files to work with and saves
        the literal file name.
    For each trigger, a search string is built and the first
        file matching the pattern is saved.
    Does not yet handle multiple input files (will need to modify
        other methods as well).
    On error, it sets $self->{success} = 'false';
    This method returns nothing

=head2  _determine_output_file_names

    Checks the journal acronym against a list and builds an
        ouput file name based on job data.
    A default is built if the jcode is not known.
    On error, it sets $self->{success} = 'false';
    This method returns nothing

=head2  _deliver_renamed_file

    This method makes a copy of the input file with the
        new file name in the output folder and moves the
        old file to the _sent folder (without renaming).
    File paths are checked for existance before moves.
    On error, it sets $self->{success} = 'false';
    This method returns nothing

=head2  _clean_up

    Trigger files are moved from the in folder to the
        out (archive) folder.
    Activity log is written.
    _prune_logs is called.
    On error, it sets $self->{success} = 'false';
    This method returns nothing

=head2  _prune_logs

    Reads the names of all log files and parses them.
    Deletes all logs that have a file name indicating they
        are older than 30 days.
    $log_retention_days is hardcoded but easy to alter.
    This method does not set $self->{success} on error, since
        it is not vital to the module functioning.
    This method returns nothing.

=head2  _error_handler

    If any other method has set $self->{success} = 'false',
        then this method generates an error log and mails it
        to a system administrator.
    Trigger files are moved to the out folder to prevent
        retries on a failed job.
    Email information is retrieved from AP Locator.
    An error log is written locally and attached to an email.
    If writing the error log fails, the method will attempt
        to send mail anyway.
    On error, it sets $self->{success} = 'false';
    This method returns nothing

=head2  _debug_handler

    If run mode is 'debug', this method will be called at
        the end of the module (unless _error_handler was called)
    It generates a debug file which is just like the error
        log files, and goes to the same location.

=head1 DEPENDENCIES

    Try::Tiny           # for try()catch();
    English             # for punctuation variables
    Carp                # for carp and croak
    File::Copy          # for move and copy
    File::Slurp         # for read_file
    DateTime            # for date stamps
    Data::Dumper        # for error logs
    MIME::Lite          # for sending mail with attachments
    AP::Logger::Role    # for logging
    AP::Locatorable     # for locator app parameters
    feature 'switch'    # for 'for( when{} )' type switching

=head1 CONFIGURATION AND ENVIRONMENT

    Works ok in perl 5.10.
    Works better in 5.12 (copy function can have periods
        in destination file name).
    The server name 'FV1' is hard coded in to some messages.
    Seems to run ok in both Windows and Linux environments.
    Module relies on a cron type function to call it regularly.
    See the wiki for details.  Link is in the SUPPORT section.

=head1 DIAGNOSTICS

    View error logs or try calling module in debug mode.

=head1 INCOMPATIBILITIES

    None found yet.

=head1 BUGS AND LIMITATIONS

    See the wiki.  Link is in the SUPPORT section.

=head1 AUTHOR

Joe Henderson, C<< <jhenderson@allenpress.com> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc AP::PDF::Renamer

An AP Wiki entry exists at

    http://wiki.allenpress.net/wiki/PDF_Renamer

=head1 LICENSE AND COPYRIGHT

    Copyright 2014 Allen Press, Inc.
    This program is released under the following license: restrictive
