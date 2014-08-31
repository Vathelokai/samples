#!perl -T

use strict;
use warnings;

use Test::More tests => 4;
use File::Slurp;
use Text::Diff;

# Load input file with File::Slurp
my $input = read_file('t/inputs/10695_with_parenthesis.input');

# Ensure that $input isn't empty
isnt($input, undef, "Finding 10695_with_parenthesis.input");

####################################
# Perform the regexp on $input
####################################

my $doc_type = 'NLM3.0Arch';
my $args = { full_xml => $input, };
my $params = {
    author_count_first  => '2',
    author_count_other  => '2',
    truncate_text       => '&space;et al.',
};
use_ok('AP::Style::Modules::Rule10695');

my $module = AP::Style::Modules::Rule10695->new(
		     $doc_type,
		     {
			level       => 'trace', # options: { trace | debug | info | warning | error | fatal }
			destination => {
				       off => 1,
				       #logfile => 't\\10695_with_parenthesis.log',
				       # options : { off => 1 | stderr => 1 | stdout => 1 | logfile => '\\file.txt'}
				       },
		     },
);

# process each each container, one at a time
my @whole_articles;
my $allowed_elements = '(?:article)';

# prep $input
while ( $input =~ s{\t}{<^myTab^>}xmsig ){};
while ( $input =~ s{\n}{<^myLineBreak^>}xmsig ){};

# extract and process
while ( $input =~ s{(<($allowed_elements)[ >](?:(?!</\2>).)*</\2>)}{<<^whole_article^>>}xmsi ){
   my $whole_article = $1;
   $whole_article = $module->execute( $whole_article, $args, $params );
   push @whole_articles, $whole_article;
}

# put processed parts back
foreach (@whole_articles){
    $input =~ s{<<\^whole_article\^>>}{$_}xmsi
}

# prettify $input
while ( $input =~ s{<\^myTab\^>}{"\t"}exmsig ){};
while ( $input =~ s{<\^myLineBreak\^>}{"\n"}exmsig ){};

######################################
# Compare them to the on disk results
######################################
my $output = read_file('t/outputs/10695_with_parenthesis.output');

isnt($output, undef, "Finding 10695_with_parenthesis.output");

ok( $input eq $output,
    "Output of regex differs from expected:\n" . diff( \$output, \$input ) );
