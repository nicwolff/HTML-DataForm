use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'HTML::DataForm',
    license             => 'perl',
    dist_author         => q{Nic Wolff <nic@angel.net>},
    dist_version_from   => 'lib/HTML/DataForm.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'HTML-DataForm-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
