package WebService::Lancers::Response;

use warnings;
use strict;
use Carp;

use Hash::AsObject;
use Time::Piece qw//;
use XML::LibXML;

sub new {
	my ($class, $decoded_content) = @_;
	my $s = bless({}, $class);

	$s->{response} = $decoded_content;
	$s->{items} = undef;
	$s->{index} = -1;

	$s->_parse();

	return $s;
}

sub next {
	my $s = shift;
	$s->{index} += 1;

	my $item = $s->{items}->[ $s->{index} ];
	if(!defined $item){
		return;
	}

	my $id = undef;
	if($item->findvalue('link') =~ /detail\/(\w+)/){
		$id = $1;
	}

	my $hash = {
		id => $id,
		title => Encode::encode_utf8( $item->findvalue('title') ),
		date => Time::Piece->strptime( $item->findvalue('pubDate'), '%a, %d %b %Y %H:%M:%S %z' ),
		description => Encode::encode_utf8( $item->findvalue('description') ),
		url => $item->findvalue('link'),
	};

	return Hash::AsObject->new( $hash );
}

sub _parse {
	my $s = shift;

	my $xml_parser = XML::LibXML->new();
	my $dom = $xml_parser->parse_string($s->{response});
	$s->{items} = $dom->findnodes('//channel/item');
}

1;
__END__
=head1 NAME

WebService::Lancers::Response

=head1 SYNOPSIS

Please see POD for WebService::Lancers.

L<https://github.com/mugifly/p5-WebService-Lancers/README.pod>

=head1 METHODS

=head2 new ( ... )

=head2 next ( )

Get a next item (work), from the fetched items in instance.

The item that you got is an object.

You can use the getter-methods:

=over 4

=item * id - ID of work

=item * title - Title of work

=item * date - Date of work (Time::Piece object)

=item * url - URL of work

=back

=head1 SEE ALSO

L<https://github.com/mugifly/p5-WebService-Lancers/>

L<Hash::AsObject>

L<Time::Piece>

=head1 COPYRIGHT AND LICENSE

Please see POD for WebService::Lancers.

L<https://github.com/mugifly/p5-WebService-Lancers/README.pod>