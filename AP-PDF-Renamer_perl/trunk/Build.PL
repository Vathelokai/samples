use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'AP::PDF::Renamer',
    license             => 'restrictive',
    dist_author         => q{Joseph Henderson <jhenderson@allenpress.com>},
    dist_version_from   => 'lib/AP/PDF/Renamer.pm',
    build_requires => {
        'AP::PDF::Renamer' => 0,
        'Test::More' => 0,
        'Text::Diff' => 0,
    },
    requires => {
        'Moose' => 0,
        'DateTime' => 0,
        'MIME::Lite'  => 0,
        'Try::Tiny'  => 0,
        'File::Slurp'  => 0,
        'Path::Class' => 0,
        'AP::Logger::Role' => 0,
        'AP::Locatorable' => 0,
        'Test::More' => 0,
        'Text::Diff' => 0,
    },
    add_to_cleanup      => [ 'AP-pdf-renamer*' ],
);

$builder->create_build_script();
