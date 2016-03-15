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
	rcynicl => "/home/baerm/wtemp/rcynic/lrcynic.xml",
	rcynicr => "/home/baerm/wtemp/rcynic/rrcynic.xml"
	);

    my $data = rpkiRtrRcynicStatus::rpkiRtrRcynicStatus_getData(\%config);

    my %tdata = (
	'rcynic1' =>
	{
	    ROAInformation =>
	    {
		ROAsCurrent => int(rand 10000),
		ROAsAdded => 4224,
		KeysCurrent => 0,
		KeysAdded => 0,
	    },

	    WarningInfo =>
	    {
		FailedValidation => 2,
		MissingObjects => 2,
		NotSubset => 2,
		Rejected => 2,
		CPS => 361,
		StaleCRL => 2161,
		StaleManifest => 2163,
	    },

	    DataSources =>
		[
		 ['202.30.51.27', 'Yes'],
		 ['ca0.rpki.net', 'No'],
		 ['localcert.ripe.net', 'No'],
		 ['localhost:10873', 'Yes'],
		 ['main', 'Yes'],
		 ['repo0.rpki.net', 'Yes'],
		 ['repository.lacnic.net', 'No'],
		 ['rpki-02.rarc.net', 'Yes'],
		 ['rpki-repository.nic.ad.jp', 'Yes'],
		 ['rpki-testbed.apnic.net', 'No'],
		 ['rpki.afrinic.net', 'No'],
		 ['rpki.apnic.net', 'No'],
		 ['rpki.rarc.net', 'Yes'],
		 ['rpki.ripe.net', 'Yes']
		]
	},

	'cache2' =>
	{
	    ROAInformation =>
	    {
		ROAsCurrent => 0 - int(rand 10000),
		ROAsAdded => 4224,
		KeysCurrent => 0,
		KeysAdded => 0,
	    },

	    WarningInfo =>
	    {
		FailedValidation => 2,
		MissingObjects => 2,
		NotSubset => 2,
		Rejected => 2,
		CPS => 361,
		StaleCRL => 2161,
		StaleManifest => 2163,
	    },

	    DataSources =>
		[
		 ['202.30.51.27', 'Yes'],
		 ['ca0.rpki.net', 'No'],
		 ['localcert.ripe.net', 'No'],
		 ['localhost:10873', 'Yes'],
		 ['main', 'Yes'],
		 ['repo0.rpki.net', 'Yes'],
		 ['repository.lacnic.net', 'No'],
		 ['rpki-02.rarc.net', 'Yes'],
		 ['rpki-repository.nic.ad.jp', 'Yes'],
		 ['rpki-testbed.apnic.net', 'No'],
		 ['rpki.afrinic.net', 'No'],
		 ['rpki.apnic.net', 'No'],
		 ['rpki.rarc.net', 'Yes'],
		 ['rpki.ripe.net', 'Yes']
		]
	},
	
	);	            

    return $data;
#    return \%tdata;
};

get '/rcynic-status' => sub {
	return template 'rcynic-status';
};

true;
