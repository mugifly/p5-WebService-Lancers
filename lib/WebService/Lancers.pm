package WebService::Lancers;

use warnings;
use strict;
use Carp;

use Encode;
use HTML::TreeBuilder;
use LWP::UserAgent;
use URI;
use WebService::Lancers::Response;

use version;
our $VERSION = qv('1.0.0');

our %FETCH_WORK_PARAMS = (
	# Keyword
	keyword => '',
	# Category
	parent_category => '',
	# Money
	money_min => '',	money_max => '',
	# Type
	typeCompetition => 1,	typeProject => 1,	typeTask => 1,
	# Filter
	feedback => 0,	identification => 0,	lancers_check => 0,
	nda => 0,	approval_rate => 0,	award_guarantee => 0,
	new => 0,	hurry => 0,	feature => 0,	completed => 1,
	# Page
	page => 0,
);

# Constructor
sub new {
	my ($class, %params) = @_;
	my $s = bless({}, $class);

	$s->{ua} = $params{ua} || LWP::UserAgent->new();
	$s->{last_request} = undef;
	$s->{last_response} = undef;

	$s->{dry_run} = $params{dry_run} || 0;

	$s->{base_url} = $params{base_url} || 'http://www.lancers.jp/';

	return $s;
}

# Fetch the works
sub fetch_work {
	my ($s, %params) = @_;

	# Check the parameters (Set the default value)
	foreach (keys %FETCH_WORK_PARAMS){
		$params{$_} = $FETCH_WORK_PARAMS{$_} unless(defined $params{$_});
	}

	# Fetch and set a key
	my ($key, $token) = $s->_fetch_search_key_and_token();
	$params{key} = $params{key} || $key;

	# Generate the search request
	my $request = HTTP::Request->new( GET => $s->_generate_get_uri($s->{base_url}.'work/retrieval.rss', \%params) );
	$s->{last_request} = $request;

	# Request
	return if($s->{dry_run});
	my $response = $s->{ua}->request( $request );
	$s->{last_response} = $response;
	if($response->is_error){
		die $response->statue_line;
	}

	# Parse the response
	return WebService::Lancers::Response->new( $response->decoded_content );
}

# Get/Set the Useragent object
sub useragent {
	my $s = shift;
	my $ua = shift || undef;
	if(defined $ua){
		$s->{ua} = $ua;
	}
	return $s->{ua};
}

# Get the last request
sub last_request {
	my $s = shift;
	return $s->{last_request};
}

# Get the last response
sub last_response {
	my $s = shift;
	return $s->{last_response};
}

sub _fetch_search_key_and_token {
	my $s = shift;
	return ("abcdefghijklmnopqrstuvwxyz", "Token012345") if($s->{dry_run});

	my $response = $s->{ua}->get( $s->{base_url}.'work/search?normal' );
	if ($response->is_error) {
		die $response->statue_line;
	}

	my $tree = HTML::TreeBuilder->new;
	$tree->parse($response->decoded_content);
	my @items = $tree->look_down('id', 'searchForm')->look_down('name', 'key');
	my @tags = $items[0]->find('input');

	my $key = $tags[0]->attr('value') || die "Can't fetch the search key(token).";
	my $token = $tags[0]->attr('id');

	$tree = $tree->delete;

	return ($key, $token);
}

sub _generate_get_uri {
	my ($s, $url, $params_ref) = @_;
	my $uri = URI->new($url);
	$uri->query_form($params_ref);
	return $uri->as_string();
}

1;
__END__
=head1 NAME

WebService::Lancers - Scrapping module with perl5 for the Lancers website

=head1 NOTICE

This modules is UNOFFICIAL, released as ALPHA version.
Please use this under the SELF-RESPONSIBILITY ;)

Your feedback is highly appreciated.

=head1 SYNOPSIS

  use WebService::Lancers;
  
  my $c = WebService::Lancers->new();
  
  # Request works
  my $response = $c->fetch_work( keyword => 'perl' );
  
  # Print each works title
  while ( my $work = $response->next ){
        print $work->title . "(id:". $work->id .")\n";
        print $work->url."\n";
        print $work->date->strftime("%Y-%m-%d %H:%M:%S %z")."\n";
        print "\n";
  }

=head1 INSTALLATION (from GitHub)

  $ git clone git://github.com/mugifly/p5-WebService-Lancers.git
  $ cpanm ./p5-WebService-Lancers

=head1 METHODS

=head2 new ( [%params] )

Create an instance of WebService::Lancers.

=head3 %params (Optional) : 

=over 4

=item * ua : Any LWP::UserAgent instance.

=back

=head2 fetch_work ( [%params] )

Fetch the works from Lancers web-site.

Then, return an instance of WebService::Lancers::Response.

L<https://github.com/mugifly/p5-WebService-Lancers/blob/master/lib/WebService/Lancers/Response.pm>

=head2 useragent ( [$user_agent_object] )

Get or Set the UserAgent instance (like the LWP::UserAgent).

=head2 last_request ()

Get the last request as an instance of L<HTTP::Request>.

=head2 last_response ()

Get the last request as an instance of L<HTTP::Response>.

=head1 SEE ALSO

L<https://github.com/mugifly/p5-WebService-Lancers/>

L<Hash::AsObject>

L<LWP::UserAgent>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Masanori Ohgita (http://ohgita.info/).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
