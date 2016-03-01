package rpkiMonitorGui;
use Dancer ':syntax';
use strict;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/rpki-rtr-client-monitor-data' => sub {

	my %data = (
	            date => '2016-02-15 23:11:05',
	            sources => [
	                        ['ipv4::141.22.28.222::23072',  'INTEGER: up(1)'],
	                        ['ipvnone::141.22.28.222::23073',  'INTEGER: up(1)'],
	                       ],
	            prefixInfo => {
	                           Current => 19985,
	                           Since => '2016-02-15 23:11:05',
	                           Added => 20048,
	                           Deleted => 63
	                          }
	           );

	return \%data;

};

get '/rpki-rtr-client-monitor' => sub {
	
	my %data = (
	            date => '2016-02-15 23:11:05',
	            sources => [
	                        ['ipv4::141.22.28.222::23072',  'INTEGER: up(1)'],
	                        ['ipvnone::141.22.28.222::23073',  'INTEGER: up(1)'],
	                       ],
	            prefixInfo => {
	                           Current => 19985,
	                           Since => '2016-02-15 23:11:05',
	                           Added => 20048,
	                           Deleted => 63
	                          }
	           );

	return template 'rpki-rtr-client-monitor' => \%data;
};

get '/rcynic-status' => sub {
	my %data = (
	            ROAInformation =>
	            {
	             ROAsCurrent => 4224,
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
	           );	            

	return template 'rcynic-status' => \%data;
};

true;
