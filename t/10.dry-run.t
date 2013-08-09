use Test::More;

use WebService::Lancers;
use URI;
use Data::Dumper;

my $c = WebService::Lancers->new(
	dry_run		=>	1, 
	base_url		=> 	'http://example.com/',
);

# Get the search key and token
my ($key, $token) = $c->_fetch_search_key_and_token();
is($key, 'abcdefghijklmnopqrstuvwxyz', "(dry-run) fetch_search_key_and_token - key");
is($token, 'Token012345', "(dry-run) fetch_search_key_and_token - token");

# Generate the search request
my $response = $c->fetch_work( keyword => 'perl' );
like($c->last_request->uri, qr|^http://example.com/work/retrieval\.rss\?.*$| ,"(dry-run) fetch_work - request uri");

# Check the parameters of request
my $uri = URI->new( $c->last_request->uri );
my %params = $uri->query_form();

is($params{key}, 'abcdefghijklmnopqrstuvwxyz', "(dry-run) fetch_work - request parames - key");
is($params{keyword}, 'perl', "(dry-run) fetch_work - request parames - keyword");

foreach (keys %{WebService::Lancers::FETCH_WORK_PARAMS}){
	if($_ ne 'keyword'){
		is($params{$_}, $WebService::Lancers::FETCH_WORK_PARAMS{$_}, "(dry-run) fetch_work - request params - $_");
	}
}

done_testing();