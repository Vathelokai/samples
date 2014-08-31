#! c:\perl\bin

use strict;
use warnings;
use AP::PDF::Renamer;

our $VERSION = '0.0.1';

my $renamer = AP::PDF::Renamer->new(
            locator => { app_name => 'AP::PDF::Renamer', key => 'slitebresi' },
            logger =>{
                    level       => 'trace',
                    destination => { off => 1, },
                    #destination => { logfile => '/smb_shares/pdf_renamer/logs/live_logger.log', },
                }
);

$renamer->execute($ARGV[0]);
