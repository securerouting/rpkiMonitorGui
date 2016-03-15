package rpkiMonitorGui;
use Dancer ':syntax';
use strict;

use Data::Dumper;
use rpkiRtrClientMonitor;
use rpkiRtrRcynicStatus;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/rpki-rtr-client-monitor-data' => sub {

    my %config = (
	   hosts => [
	       { name     => "router1",
		 location => "127.0.0.1:16161",
		 password =>  "v2user",
	       },
           ],
       );
    
    my $data = rpkiRtrClientMonitor::rpkiRtrClientMonitor_getData(\%config);

    return $data;

};

get '/rpki-rtr-client-monitor' => sub {
	return template 'rpki-rtr-client-monitor';
};

get '/rcynic-status-data' => sub {
    my %config = (
	rcynicl => "rcynic-data/lrcynic.xml",
	rcynicr => "rcynic-data/rrcynic.xml"
	);

    my $data = rpkiRtrRcynicStatus::rpkiRtrRcynicStatus_getData(\%config);

    return $data;
};

get '/rcynic-status' => sub {
	return template 'rcynic-status';
};

true;
