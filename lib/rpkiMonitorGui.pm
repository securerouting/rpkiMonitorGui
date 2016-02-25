package rpkiMonitorGui;
use Dancer ':syntax';
use strict;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/rpki-rtr-client-monitor' => sub {

	my %vars = (
	            date => '2016-02-15 23:11:05',
	            sources => [
	                        ['ipv4::141.22.28.222::23072',  'INTEGER: up(1)'],
	                       ],
	            prefixInfo => {
	                           Current => 19985,
	                           Since => '2016-02-15 23:11:05',
	                           Added => 20048,
	                           Deleted => 63
	                          }
	           );
	
	return template 'rpki-rtr-client-monitor' => \%vars;
};

true;
