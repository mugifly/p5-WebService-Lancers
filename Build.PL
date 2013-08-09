use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WebService::Lancers',
    license             => 'perl',
    dist_abstract	=> 'Scrapping module with perl5 for the Lancers website',
    dist_author         => 'Masanori Ohgita (http://ohgita.info/)',
    dist_version_from   => 'lib/WebService/Lancers.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
        'Encode' => 0,
        'LWP::UserAgent' => 0,
        'XML::LibXML' => 0,
        'URI' => 0,
        'HTML::TreeBuilder' => 0,
        'Hash::AsObject' => 0,
        'Time::Piece' => 0,
    },
    add_to_cleanup      => [ 'WebService-Lancers-*' ],
);

$builder->create_build_script();
