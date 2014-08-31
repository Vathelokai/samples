package AP::Style::Modules::Rule10695;

use warnings;
use strict;
use Data::Dumper;
use base 'AP::Style::Modules';

our $VERSION = '0.2.1';

sub execute {
    my $self        = shift;
    my $input       = shift;
    my $args        = shift;
    my $params      = shift;

    my $module_name = __PACKAGE__;

    $self->{logger}->info("Starting Module $module_name");

    ######################## YOUR CODE BELOW ##########################

    ##### EXPLAINS AND COMMENTS #####
    # Articles arive with a <ref-list> full of bibliography entries in the form <ref id='xxxx-00-00-00-surname1'>...</ref>.
    # Through out the article, in any location where CDATA is allowed, there are <xref ref-type='bibr'> with rid values that reference the <ref> ids.
    # There are other kinds of xref that should be ignored.  There can be multiple xref for each bibr, or none at all.
    #
    # This rule finds all of those <xref>, evaluates them, and modifies the plain text inside the tags per the param values
    #     $params->author_count_first is how many author names to show in the first xref for that rid
    #     $params->author_count_other is how many author names to show in all other xref for that rid
    #     $params->truncate_text is what text to insert where names were removed
    #
    # This rule reorders the xml so that footnotes are after the body text. Afterward, it restores the original order of the xml elements.
    #     It makes finding the 'first' reference callout easier.
    #
    # The test files have tabs and linebreaks.  These are converted to placeholder text in the *.t file and are converted back there.
    #     The live xml files will not contain either.
    #
    # Throughout the module, data is stored in 6 shared objects
    #     $self              hashref      default perl module stuff, contains Logger
    #     $input             string       xml string recieved
    #     $input_backup      string       copy of input, for emergencies
    #     $params            hashref      hash of hash, each param and their values
    #     $xrefs             hashref      hash of hash, all the xrefs in the input xml, as well as their metadata
    #     $return_value      string       either "true" or "false", used repeatedly for sub's returning errors
    #
    


    ##### PREPARE #####
    $self->{logger}->debug("\tRecieved \$input: \"$input\""); # should be <article>...</article> xml string
    $self->{logger}->trace("\tRecieved \$params->\{\'author_count_first\'\}: \"$params->{'author_count_first'}\"");
    $self->{logger}->trace("\tRecieved \$params->\{\'author_count_other\'\}: \"$params->{'author_count_other'}\"");
    $self->{logger}->trace("\tRecieved \$params->\{\'truncate_text\'\}: \"$params->{'truncate_text'}\"");
    my $input_backup = $input; # backup copy to return in case of errors
    my $return_value; # true/false string, used repeatedly
    my $xrefs = {}; # we will build and use this hashref throughout
    #  $xrefs->{'id'}->{'found_string'}    # xref extracted from $input text
    #                ->{'output_string'}   # copy of found_string that is modified
    #                ->{'name_count'}      # number of names in found_string
    #                ->{'isFirst'}         # true/false of if it's the first one
    #                ->{'location'}        # number of characters before the found_string
    #                ->{'rid'}             # which reference the xref points to

    ##### CHECK RUN CONDITIONS #####
    $return_value = _check_run_conditions($self,$input,$params);
    if( $return_value eq 'true' ){ return $input_backup };

    ##### PARAM CLEANING #####
    $return_value = _clean_params($self,$params);
    if( $return_value eq 'true' ){ return $input_backup };

    ##### MOVE FOOTNOTES TO END #####
    $input = _move_body_footnotes_to_end($self,$input);

    ##### EXTRACT XREFS FROM INPUT #####
    $input = _extract_xrefs_from_input($self,$input,$xrefs);

    ##### FIND FIRST XREF #####
    $return_value = _find_first_xrefs($self,$xrefs);
    if( $return_value eq 'true' ){ return $input_backup };

    ##### COUNT NAMES #####
    $return_value = _count_names_in_each_xref($self,$xrefs);
    if( $return_value eq 'true' ){ return $input_backup };

    ##### FIX FIRST CALLOUT #####
    $return_value = _fix_first_callout($self,$xrefs, $params);
    if( $return_value eq 'true' ){ return $input_backup };

    ##### FIX ALL OTHER CALLOUTS #####
    $return_value = _fix_all_other_callouts($self,$xrefs, $params);
    if( $return_value eq 'true' ){ return $input_backup };

    ##### RESTORE FOOTNOTES TO BODY #####
    $input = _move_body_footnotes_back($self,$input);

    ##### RETURN CORRECTIONS TO TEXT #####
    $input = _return_corrections_to_text($self,$input,$xrefs);

    ##### DONE #####
    $self->{logger}->debug("\tReturned \$input: \"$input\"");

    ######################## YOUR CODE ABOVE ##########################

    $self->{logger}->info("Completing Module $module_name\n");

    return $input;

} # end of main execute()

sub _check_run_conditions{
    my $self          = shift;
    my $input         = shift; # string
    my $params        = shift; # hashref
    my $return_value  = 'false'; # should we quit now?

    # if param is not valid
    if (
        $params->{'author_count_first'} !~ m{^all$}xmsi
        &&
        $params->{'author_count_first'} !~ m{^[0-9]+$}xms
       ) {
        # anything that is not 'all' or a number
        $self->{logger}->debug("\t\$params->\{\'author_count_first\'\} is non-numeric.  Exiting.");
        $return_value = 'true';
    }

    # if param is not valid
    if (
        $params->{'author_count_other'} !~ m{^all$}xmsi
        &&
        $params->{'author_count_other'} !~ m{^[0-9]+$}xms
       ) {
        # anything that is not 'all' or a number
        $self->{logger}->debug("\t\$params->\{\'author_count_other\'\} is non-numeric.  Exiting.");
        $return_value = 'true';
    }

    # $params->{'truncate_text'} is the text to insert where the author names were deleted
    if (
        $params->{'truncate_text'} =~ m{^n\/a$}xmsi
        ||
        $params->{'truncate_text'} =~ m{^unk(?:nown)?$}xmsi
        ||
        $params->{'truncate_text'} =~ m{^$}xms
       ) {
        $self->{logger}->debug("\t\$params->\{\'truncate_text\'\} is invalid.  Exiting.");
        $return_value = 'true';
    }

    # $input must have something to work with
    if (
        $input =~ m{^$}xms
       ) {
        $self->{logger}->debug("\t\$input is empty string.  Exiting.");
        $return_value = 'true';
    }

    # $input must have xrefs in it
    if (
        $input !~ m{<xref[ ]ref[-]type\=\"bibr\"[ ]rid\=\"}xms
       ) {
        $self->{logger}->debug("\t\$input has no xrefs.  Exiting.");
        $return_value = 'true';
    }

    return $return_value;
} # end  _check_run_conditions()

sub _clean_params{
    my $self          = shift;
    my $params        = shift; # hashref
    my $return_value  = 'false'; # should we quit now?

    # note: params have already been checked for validity by _check_run_conditions()

    # $params->{'author_count_other'} and $params->{'author_count_first'} are the
    #    number of author names to show before truncating the list
    # treat 'all' like a huge number
    if ($params->{'author_count_other'} =~ m{^all$}xmsi) {
        $params->{'author_count_other'} = '999';
    }
    if ($params->{'author_count_first'} =~ m{^all$}xms) {
        $params->{'author_count_first'} = '999';
    }

    # loop through all params and replace entitiy spaces with real spaces
    while (my($key,$value) = each(%$params)){
        $params->{$key} =~ s{[&](?:kb)?space[;]}{ }xmsig;
    }

    # loop through all params and replace 'none' with empty strings
    while (my($key,$value) = each(%$params)){
        $params->{$key} =~ s{^none$}{}xmsig;
    }

    $self->{logger}->debug("\tCleaned Param: \$params->\{\'author_count_first\'\}: \"$params->{'author_count_first'}\"");
    $self->{logger}->debug("\tCleaned Param: \$params->\{\'author_count_other\'\}: \"$params->{'author_count_other'}\"");
    $self->{logger}->debug("\tCleaned Param: \$params->\{\'truncate_text\'\}: \"$params->{'truncate_text'}\"");

    return $return_value;
} # end _clean_params()

sub _move_body_footnotes_to_end{
    my $self          = shift;
    my $input         = shift; # string
    my $xrefs         = shift; # hashref

    my $found_count = 0;
    my $extracts = {};

    $self->{logger}->debug("\tSearching for body footnotes with xrefs to re-order.");

    # example: <fn id="n1"><label><sup>1</sup></label><p>This is the first footnote.</p></fn>
    while ( $input =~ s{
                    (                                                             # start $1
                        <fn[ ][^>]*>                                              #   footnote tag
                        (?:(?!</fn>)(?!<<\^\_fn_placeholder[0-9]+\_\^>>).)*       #   footnote tag contents
                        <xref[ ]ref[-]type\=\"bibr\"[ ]rid\=\"                    #   that contains an xref tag
                        (?:(?!</fn>)(?!<<\^\_fn_placeholder[0-9]+\_\^>>).)*</fn>  #   the rest of the footnote
                    )                                                             # end $1
                    (                                                             # start $2
                        (?:(?!</body>).)*</body>                                  #   before the end of the article body
                    )                                                             # end $2
                    }{<<^\_fn_placeholder$found_count\_^>>$2}xmsi ){
        my $found_text = $1;
        $input =~ s{
                     (                                                            # start $1
                       <back>                                                     #   after the body
                       (?:<ref-list[ >](?:(?!</ref-list>).)*</ref-list>)?         #   after the ref-list, if it's there
                       (?:<fn-group[ >](?:(?!</fn-group>).)*</fn-group>)?         #   after the first page footnotes, if they are there
                       .*                                                         #   and any other text, just in case
                     )                                                            # end $1
                     (                                                            # start $2
                       (?:<sec>|</back>)                                          #   but before the figures, tables, appendixes, etc.
                     )                                                            # end $2
                   }{$1<fn_placeholder id="$found_count">$found_text</fn_placeholder>$2}xmsi;

        $self->{logger}->trace("\t\tMoved to end of article \$found_text: \"$found_text\"");

        $found_count++;

    } # end 'while there are body footnotes with xrefs'

    $self->{logger}->debug("\tMoved " . $found_count . " body footnotes with xrefs.");

    return $input;
} # end _move_body_footnotes_to_end()

sub _extract_xrefs_from_input{
    my $self          = shift;
    my $input         = shift; # string
    my $xrefs         = shift; # hashref

    $self->{logger}->debug("\tExtracting xrefs from article.");

    my $found_count = 0;

    # example: <xref ref-type="bibr" rid="test-01-01-01-Dumbledore1">Dumbledore, McGonagall, Snape, Umbridge, Scamander, Dippet, Black, and Fortescue 2000</xref>
    while ( $input =~ s{
                    (^.*)                                            # $1: all preceding text
                    (<xref[ ]ref[-]type\=\"bibr\"[ ]rid\=\")         # $2: xref tag up to RID
                    ([^\"]+)                                         # $3: RID value
                    (\"[^>]*>)                                       # $4: rest of xref tag
                    ((?:(?!</xref>)(?!<<\^\_xref[0-9]+\_\^>>).)*)    # $5: content of xref tag
                    (</xref>)                                        # $6: closing xref tag
                    }{$1$2$3$4<<^\_xref$found_count\_^>>$6}xms ){
        my $previous_text = $1;
        my $found_rid = $3;
        my $found_temp = $5;
        $xrefs->{$found_count}->{'found_string'}  = $found_temp;
        $xrefs->{$found_count}->{'output_string'} = $xrefs->{$found_count}->{'found_string'};
        $xrefs->{$found_count}->{'isFirst'}       = 'true'; # this default will be corrected later
        $xrefs->{$found_count}->{'rid'}           = $found_rid;
        $xrefs->{$found_count}->{'location'}      = length($previous_text);

        $self->{logger}->trace("\t\tFound \$xrefs->{$found_count}->{\'found_string\'}: \"$xrefs->{$found_count}->{'found_string'}\"");

        $found_count++;

    } # end 'while there are xrefs'
    $self->{logger}->debug("\tFound " . $found_count . " xrefs.");

    return $input;
} # end _extract_xrefs_from_input()

sub _find_first_xrefs{
    my $self          = shift;
    my $xrefs         = shift; # hashref
    my $return_value  = 'false'; # should we quit now?

    # slow but workable way of doing this
    # make a copy of the hash and compare element-by-element
    #    to find each RID with the with the lowest location

    $self->{logger}->debug("\tFinding the first xref for each RID in the article.");

    my %xrefs_copy = %$xrefs;
    while (my($key_real,$value_real) = each(%$xrefs)){
        while (my($key_copy,$value_copy) = each(%xrefs_copy)){
            if (
                  # they are true by default, which means unchecked
                  $xrefs->{$key_real}->{isFirst} eq 'true'
                  &&
                  # compare same RIDs (refs to the same citation)
                  $xrefs->{$key_real}->{rid} eq $xrefs->{$key_copy}->{rid}
                  &&
                  # location is the character count of preceeding text
                  $xrefs->{$key_real}->{location} > $xrefs->{$key_copy}->{location}
               ){
                # if the location number is larger for the same RID,
                #     then it's the second one in the article
                $xrefs->{$key_real}->{isFirst} = 'false'
            }
        }
    }
    undef %xrefs_copy; # discard the copy

    # report it
    while (my $key = each(%$xrefs)){
        if ( $xrefs->{$key}->{isFirst} eq 'true' ){
            $self->{logger}->trace("\t\tMarked this as first RID.");
            $self->{logger}->trace("\t\t\t\$xrefs->{\$key}->{rid} \= \"$xrefs->{$key}->{rid}\"");
            $self->{logger}->trace("\t\t\t\$xrefs->{\$key}->{location} \= \"$xrefs->{$key}->{location}\"");
            $self->{logger}->trace("\t\t\t\$xrefs->{\$key}->{found_string} \= \"$xrefs->{$key}->{found_string}\"");
        }
    }

    $self->{logger}->debug("\tAll isFirst RIDs marked.");

    return $return_value;
} # end _find_first_xrefs()

sub _count_names_in_each_xref{
    my $self          = shift;
    my $xrefs         = shift; # hashref
    my $return_value  = 'false'; # should we quit now?

    my $surname_prefixes = '(?i: d[aei]l?(?:[ ]l[ao]s)? | v[ao]n(?:[ ]der)? )';
    my $regex = '
                (
                    (?:and[ ]|[&]amp[;])?[ ]?
                    (?:$surname_prefixes)?[ ]?
                    (?:[A-Z&;][a-z&;-]+)
                )
                (?=[,]|[ ](?:and[ ]|[&]amp[;])|[ ](?:et[ ]al)|[ ][0-9][0-9][0-9][0-9]|$)
                ';

    $self->{logger}->debug("\tCounting names in each callout.");

    # count names in each xref
    while ( my($key) = each(%$xrefs) ){
        # count names via regex trick
        $xrefs->{$key}->{'name_count'} =
            $xrefs->{$key}->{'output_string'} =~ s{$regex}{$1}gxmsi;
        $self->{logger}->trace("\t\tCounted \"$xrefs->{$key}->{'name_count'}\" names in \"$xrefs->{$key}->{'output_string'}\"");

        # if the count is null for some reason, set it to 1
        if ( $xrefs->{$key}->{'name_count'} !~ m{^[0-9]+$}xms ){
            $self->{logger}->trace("\t\t\tNo names counted.  Treating this reference as 1 name.");
            $xrefs->{$key}->{'name_count'} = 1;
        }

        # if the name list has "et al" in it, add 2 to the name
        if ( $xrefs->{$key}->{'output_string'} =~ m{(?:[,]?[ ]et[ ]al[\.]?)}xmsi ){
            $self->{logger}->trace("\t\t\tFound \"et al.\" in \$xrefs->{\$key}->{\'output_string\'}\.  Adding 2 to name count\.");
            $xrefs->{$key}->{'name_count'} = $xrefs->{$key}->{'name_count'} + 2;
        }
    }

    $self->{logger}->debug("\tFinished counting names in each callout.");

    return $return_value;

} # end _count_names_in_each_xref()

sub _fix_first_callout{
    my $self          = shift;
    my $xrefs         = shift;   # hashref
    my $params        = shift;   # input params
    my $return_value  = 'false'; # should we quit now?

    my $surname_prefixes = '(?i: d[aei]l?(?:[ ]l[ao]s)? | v[ao]n(?:[ ]der)? )';
    my $regex = '                                                 ' # this string is used as regex search later
                .'(                                               ' #   start $1
                .'    (?:and[ ]|[&]amp[;])?[ ]?                   ' #     maybe an 'and'
                .'    (?:$surname_prefixes)?[ ]?                  ' #     maybe prefixes on the name
                .'    (?:[A-Z&;][a-z&;-]+)                        ' #     a name
                .')                                               ' #   end $1
                .'(?=                                             ' #   followed by
                .'    [,]|                                        ' #     a comma, or
                .'    [ ](?:and[ ]|[&]amp[;])|                    ' #     'and', or
                .'    [ ](?:et[ ]al)|                             ' #     et al, or
                .'    [ ][\(]?[0-9][0-9][0-9][0-9][\)]?|          ' #     the year, or
                .'    $                                           ' #     the end of the string
                .')                                               ' #     
                .'(?:(?![ ][\(]?[0-9][0-9][0-9][0-9][\)]?).)*     ' #   anything after that which is not the year
                .'';                                                # end of string

    $self->{logger}->debug("\tFixing first callout for each RID.");

    # modify xref string to truncate extra author names - first of each xref
    while ( my($key) = each(%$xrefs) ){ # check each xref
        if ( ($xrefs->{$key}->{'isFirst'} =~ m{true}xms) ){ # if this is the first reference for the RID
            if ( ($xrefs->{$key}->{'name_count'} >= $params->{'author_count_first'} ) ){ # and if there are enough names to work with
            
                   $self->{logger}->trace("\t\tCounted enough names and isFirst.");
                   $self->{logger}->trace("\t\t\tXREF before - \$xrefs->{$key}->{\'output_string\'}: $xrefs->{$key}->{'output_string'}\"");
                   
                   $xrefs->{$key}->{'output_string'} =~ s{$regex}{$1$params->{'truncate_text'}}xmsi;
                   
                   $self->{logger}->trace("\t\t\tXREF after  - \$xrefs->{$key}->{\'output_string\'}: \"$xrefs->{$key}->{'output_string'}\"");
            }else{
                
                $self->{logger}->trace("\t\tNot enough names found in xref.  Keeping it as is.");
                $self->{logger}->trace("\t\t\tXREF        - \$params->{\'author_count_first\'}: \= \"$params->{'author_count_first'}\"");
                
                $self->{logger}->trace("\t\t\tXREF        - \$xrefs->{$key}->{\'name_count\'}: \= \"$xrefs->{$key}->{'name_count'}\"");
                
                $self->{logger}->trace("\t\t\tXREF        - \$xrefs->{$key}->{\'output_string\'}: $xrefs->{$key}->{'output_string'}\"");
            } # end 'if enough names are counted'
        
        }else{
            
            $self->{logger}->trace("\t\tThis is not first reference for the RID.  Keeping it as is.");
            $self->{logger}->trace("\t\t\tXREF        - \$xrefs->{$key}->{\'isFirst\'}: $xrefs->{$key}->{'isFirst'}\"");
            $self->{logger}->trace("\t\t\tXREF        - \$xrefs->{$key}->{\'output_string\'}: $xrefs->{$key}->{'output_string'}\"");
        
        } # end 'if not the first reference'

    } # end 'while each key in $xrefs'

    $self->{logger}->debug("\tFinished fixing first callout for each RID.");

    return $return_value;

} # end of _fix_first_callout()

sub _fix_all_other_callouts{
    my $self          = shift;
    my $xrefs         = shift;   # hashref
    my $params        = shift;   # input params
    my $return_value  = 'false'; # should we quit now?

    my $surname_prefixes = '(?i: d[aei]l?(?:[ ]l[ao]s)? | v[ao]n(?:[ ]der)? )';
    my $regex = '                                                 ' # this string is used as regex search later
                .'(                                               ' #   start $1
                .'    (?:and[ ]|[&]amp[;])?[ ]?                   ' #     maybe an 'and'
                .'    (?:$surname_prefixes)?[ ]?                  ' #     maybe prefixes on the name
                .'    (?:[A-Z&;][a-z&;-]+)                        ' #     a name
                .')                                               ' #   end $1
                .'(?=                                             ' #   followed by
                .'    [,]|                                        ' #     a comma, or
                .'    [ ](?:and[ ]|[&]amp[;])|                    ' #     'and', or
                .'    [ ](?:et[ ]al)|                             ' #     et al, or
                .'    [ ][\(]?[0-9][0-9][0-9][0-9][\)]?|          ' #     the year, or
                .'    $                                           ' #     the end of the string
                .')                                               ' #     
                .'(?:(?![ ][\(]?[0-9][0-9][0-9][0-9][\)]?).)*     ' #   anything after that which is not the year
                .'';                                                # end of string

    $self->{logger}->debug("\tFixing all other callouts.");

    # modify xref string to truncate extra author names - all other xrefs
    while ( my($key) = each(%$xrefs) ){ # check each xref
        if ( ($xrefs->{$key}->{'isFirst'} !~ m{true}xms) ){ # if this is not the first reference for the RID
            if ( ($xrefs->{$key}->{'name_count'} >= $params->{'author_count_other'} ) ){ # and if there are enough names to work with
                   
                   $self->{logger}->trace("\t\tCounted enough names and is not the first reference for the RID.");
                   $self->{logger}->trace("\t\t\tXREF before - \$xrefs->{$key}->{\'output_string\'}: $xrefs->{$key}->{'output_string'}\"");
                   
                   $xrefs->{$key}->{'output_string'} =~ s{$regex}{$1$params->{'truncate_text'}}xmsi;
                   
                   $self->{logger}->trace("\t\t\tXREF after  - \$xrefs->{$key}->{\'output_string\'}: \"$xrefs->{$key}->{'output_string'}\"");
            }else{
                
                $self->{logger}->trace("\t\tNot enough names found in xref.  Keeping it as is.");
                $self->{logger}->trace("\t\t\tXREF        - \$params->{\'author_count_other\'}: \= \"$params->{'author_count_other'}\"");
                $self->{logger}->trace("\t\t\tXREF        - \$xrefs->{$key}->{\'name_count\'}: \= \"$xrefs->{$key}->{'name_count'}\"");
                $self->{logger}->trace("\t\t\tXREF        - \$xrefs->{$key}->{\'output_string\'}: $xrefs->{$key}->{'output_string'}\"");
            
            } # end 'if enough names are counted'
        }else{
            
            $self->{logger}->trace("\t\tThis is the first reference for the RID.  Keeping it as is.");
            $self->{logger}->trace("\t\t\tXREF        - \$xrefs->{$key}->{\'isFirst\'}: $xrefs->{$key}->{'isFirst'}\"");
            $self->{logger}->trace("\t\t\tXREF        - \$xrefs->{$key}->{\'output_string\'}: $xrefs->{$key}->{'output_string'}\"");
        
        } # end 'if not the first reference'

    } # end 'while each key in $xrefs'

    $self->{logger}->debug("\tFinished fixing all other callouts.");

    return $return_value;
} # end of _fix_all_other_callouts()

sub _move_body_footnotes_back{
    my $self          = shift;
    my $input         = shift; # string

    $self->{logger}->debug("\tRestoring the placement of body footnotes.");

    # extract footnotes from end of article
    while ( $input =~ s{
                       <fn\_placeholder[ ]id\=\"
                       ([0-9]+)
                       \"\>
                       ((?:(?!</fn_placeholder>).)*)
                       </fn_placeholder>
                       }{}xmsi 
          ){
        my $fn_id = $1;
        my $fn_content = $2;
        
        # replace the placeholder in the body with the extracted text
        $input =~ s{\<\<\^\_fn\_placeholder$fn_id\_\^\>\>}{$fn_content}xmsi;
        
        $self->{logger}->trace("\t\tRestored \$fn_content: \"$fn_content\"");
    }

    $self->{logger}->debug("\tFinished restoring the placement of body footnotes.");

    return $input;
} # end of _move_body_footnotes_back()

sub _return_corrections_to_text{
    my $self        = shift;
    my $input       = shift; # string
    my $xrefs       = shift; # hashref

    $self->{logger}->trace("\t\tReturning xrefs to input");
    $self->{logger}->trace("\t\t\tInput before - \$input: \"$input\"");

    # returning fixed xrefs in %meta to $input
    while ( my($key) = each(%$xrefs) ){
        $input =~ s{<<\^\_xref$key\_\^>>}{$xrefs->{$key}->{'output_string'}}xms;
    }

    $self->{logger}->trace("\t\t\tInput after  - \$input: \"$input\"");

    return $input;
} # end of _return_corrections_to_text()

# magic 1 to end module
1;

__END__;

=head1 NAME

AP::Style::Modules::Rule10695 - author last name plus et al in reference callouts

=head1 VERSION

Version 0.2.0

=cut

=head1 SYNOPSIS

    use AP::Style::Modules::Rule10695;

    my $module = AP::Style::Modules::Rule10695->new(
        {
            level       => 'debug'
            destination => ['stdout']
        }
    );
    $input = $module->execute( $input, $args, $params ); #parameterized rule
    $input =
    ...

=head1 DESCRIPTION

    This module is a sub-class of AP::Style::Modules and provides for one
    style rule overrideing the execute method of the superclass.

    This rule recieves an xml <article> to work with.
    Articles arive with a <ref-list> full of bibliography entries in the
        form <ref id='xxxx-00-00-00-surname1'>...</ref>.
    Through out the article, in any location where CDATA is allowed, there
        are <xref ref-type='bibr'> with rid values that reference
        the <ref> ids.
    There are other kinds of xref that should be ignored.  There can be
        multiple xref for each bibr, or none at all.

    This rule module finds all of those <xref>, evaluates them, and
        modifies the plain text inside the tags per the param values:
        $params->author_count_first
            is how many author names to show in the first xref for that rid
        $params->author_count_other
            is how many author names to show in all other xref for that rid
        $params->truncate_text
            is what text to insert where names were removed

    The module creates and uses this hash to do it's work.  The hashref is
        used by the various subs for evaluation/modification. Looks like...

        $xrefs->{'id'}->{'found_string'}  # xref extracted from $input text
                      ->{'output_string'} # copy of found_string to modifify
                      ->{'name_count'}    # number of names in found_string
                      ->{'isFirst'}       # true/false if it's the first one
                      ->{'location'}      # char count before the string
                      ->{'rid'}           # reference the xref points to

    This module returns a scalar of changed text, which is basically the
        <article> that it recieved, with xrefs changed.

=head1 SUBROUTINES/METHODS

=head2 execute

    Recieves $input xml text and $params hashref.
    Return a scalar of changed $input text. See SYNOPSIS.

=head2 _check_run_conditions($self,$input,$params)

    Recieves $input xml text and $params hashref.
    Evaluates input to ensure rule can/should run.
    Return a false if everything was fine, or true if there was an error.

=head2 _clean_params($self,$params)

    Recieves $params hashref.
    Evaluates, cleans, and normalizes parameter values.
    Return a false if everything was fine, or true if there was an error.

=head2 _move_body_footnotes_to_end($self,$input)

    Recieves $input xml string.
    Extracts body <fn> and moves them to the end of the body.
    Leaves a placeholder text so that things can move back later.
    Return the modified $input.

=head2 _extract_xrefs_from_input($self,$input,$xrefs)

    Recieves $input xml string and $xrefs hashref.
    Extracts xref text from $input and replaces extracted text with
        placeholders of the type '<<^_xref$found_count_^>>'.
    Places the exracted text within the $xrefs hash.  Fills in $xrefs
        such that...

        $xrefs->{$found_count}->{'found_string'}  = $found_temp;
        $xrefs->{$found_count}->{'output_string'} = $found_temp;
        $xrefs->{$found_count}->{'isFirst'}       = 'true'; # default
        $xrefs->{$found_count}->{'rid'}           = $found_rid;
        $xrefs->{$found_count}->{'location'}      = length($previous_text);

    Return the modified $input.

=head2 _find_first_xrefs($self,$xrefs)

    Recieves $xrefs hashref.
    Compares location count per each RID to determine if the found string
        is the first with that RID to appear in the article.
    Sets that value within the $xrefs hash.
    Return a false if everything was fine, or true if there was an error.

=head2 _count_names_in_each_xref($self,$xrefs)

    Recieves $xrefs hashref.
    Evaluates the found strings within the $xrefs hash and counts the
        number of names in each one.
    Sets that value within the $xrefs hash.
    Return a false if everything was fine, or true if there was an error.

=head2 _fix_first_callout($self,$xrefs, $params)

    Recieves $xrefs hashref and $params hashref.
    Finds all output strings in the $xrefs hashref where the isFirst
        value is true.
    Modifies each such output string based on values in $params hashref.
    Return a false if everything was fine, or true if there was an error.

=head2 _fix_all_other_callouts($self,$xrefs, $params)

    Recieves $xrefs hashref and $params hashref.
    Finds all output strings in the $xrefs hashref where the isFirst
        value is false.
    Modifies each such output string based on values in $params hashref.
    Return a false if everything was fine, or true if there was an error.

=head2 _move_body_footnotes_back($self,$input)

    Recieves $input xml string.
    Extracts body <fn> that were moved out of the way earlier and
        puts them back where their placeholders are in the body.
    Return the modified $input.

=head2 _return_corrections_to_text($self,$input,$xrefs)
    Return a scalar of changed text. See SYNOPSIS.
    $input = _return_corrections_to_text($input,$xrefs);

=head1 DEPENDENCIES

    AP::Style::Modules

=head1 AUTHOR

Joe Henderson, C<< <jhenderson@allenpress.com> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc AP::Style::Modules::Rule10695

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Allen Press, Inc.

This program is released under the following license: restrictive
