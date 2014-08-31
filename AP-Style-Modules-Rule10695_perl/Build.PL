use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'AP::Style::Modules::Rule10695',
    license             => 'restrictive',
    dist_author         => q{jana <jrittenhouse@allenpress.com>},
    dist_version_from   => 'lib/AP/Style/Modules/Rule10695.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'AP::Style::Modules' => 0,
    },
    add_to_cleanup      => [ 'AP-Style-Modules-Rule10695-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
