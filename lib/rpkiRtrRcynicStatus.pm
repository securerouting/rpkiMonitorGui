package rpkiRtrRcynicStatus;

use Exporter;
@EXPORT  = qw( rpkiRtrClientMonitor_getData );
$VERSION = '0.1';

use strict;
use Data::Dumper;
use XML::Simple qw(:strict);
use Getopt::Std;
use DateTime;
use DateTime::Format::Strptime;


sub rpkiRtrRcynicStatus_getData {
    my ($sourceh) = @_;

    my %data = ();
    my @empty_arrays = ();
    my $arr_p = \@empty_arrays;; 
    my $db; # xml data pointer

    # e.g. 2015-12-14T23:24:48Z'
    my $dtformat = DateTime::Format::Strptime->new(
	pattern   => '%Y-%m-%dT%H:%M:%S%Z',
	time_zone => 'local',
	on_error  => 'croak',
	);
    
    foreach my $rcName (keys %$sourceh)  {
        
	if ( $sourceh->{$rcName} !~ /.*\.xml$/ ) {
	    print STDERR "Error: file requires a .xml extension, skpping \' $sourceh->{$rcName}\'\n";
	    next;
	}

	$db=XMLin( $sourceh->{$rcName}, forcearray=>[@$arr_p], keyattr => [] );

	if ( ! exists $db->{date} ) {
	    printf STDERR "Error: No 'date' fonud in XML file \' $sourceh->{$rcName}\': Skipping\n";
	    next;
	}

	my $dt = $dtformat->parse_datetime( "$db->{date}" );

	# if ( exists $opts{d} ) {
	#     print "\n";
	#     for my $i (sort (keys %$db)) {
	# 	printf "%20.20s : \'%s\'", $i, $db->{"$i"};
	# 	my $reftype = ref $db->{"$i"};
	# 	if ( "ARRAY" eq $reftype ) {
	# 	    printf " : %i", ($#{$db->{"$i"}} + 1);
	# 	}
	# 	printf "\n";
	# 	#	printf "$i is a %s\n", $reftype;
	#     }
	# }

	my %ROAS = ();
	my %B_ROAS = ();
	my %dc = ();
	my $roa_tot = 0;
	my $back_roa_tot = 0;
	my %ext = ();
	
	my %vs_h = ();
	for my $vs ( @{$db->{"validation_status"}} ) {
	    my $t = $vs->{content};

	    if ( ( $vs->{"generation"} eq "current" ) &&
		 ( $t =~ /.*\.([^.]+)$/ )                )  {
		$ext{"$1"} += 1;
	    }

	    if ( ( $vs->{"content"} =~ /.*\.roa$/ ) )  {
		if ( $vs->{"generation"} eq "current" ) 
		{
		    if ( exists $dc{"$vs->{content}"} ) {
			$dc{$vs->{"content"}} = $dc{"$vs->{content}"} . " : " 
			    . $vs->{"status"};
		    }
		    else {
			$roa_tot++;
			$dc{"$vs->{content}"} =  $vs->{"status"};
		    }

		    $ROAS{$vs->{"status"}} += 1;
		    
		}
		elsif ( $vs->{"generation"} eq "backup" )
		{
		    $back_roa_tot++;
		    if ( exists $B_ROAS{$vs->{"status"}} ) {
			$B_ROAS{$vs->{"status"}} += 1;
		    }
		    else {
			$B_ROAS{$vs->{"status"}} = 1;
		    }
		}
	    }
	}

	$data{$rcName}{ROAInformation}{ROAsCurrent} = $ROAS{object_accepted};
	$data{$rcName}{ROAInformation}{ROAsAdded}   = $ROAS{object_accepted};

	# no router keys found currently 
	$data{$rcName}{ROAInformation}{KeysCurrent} = 0;
	$data{$rcName}{ROAInformation}{KeysAdded}   = 0;

	$data{$rcName}{WarningInfo}{FailedValidation} = 
	    $ROAS{'certificate_failed_validation'};
	$data{$rcName}{WarningInfo}{MissingObjects} = 
	    $ROAS{'manifest_lists_missing_object'};
	$data{$rcName}{WarningInfo}{NotSubset} =
	    $ROAS{'mib_openssl_X509_V_ERR_UNNESTED_RESOURCE'};
	$data{$rcName}{WarningInfo}{Rejected} =
	    $ROAS{'object_rejected'};
	$data{$rcName}{WarningInfo}{CPS} =
	    $ROAS{'policy_qualifier_cps'};
	$data{$rcName}{WarningInfo}{StaleCRL} =
	    $ROAS{'tainted_by_stale_crl'};
	$data{$rcName}{WarningInfo}{StaleManifest} =
	    $ROAS{'tainted_by_stale_manifest'};

	my %rh_h = ();
	my %unrh_h = ();

	for my $rh ( @{$db->{"rsync_history"}} ) {

	    my $val = $rh->{"content"};
	    if ( $val =~ s|^rsync://([^/]+)/.*|$1| ) {
		if ( ! exists $unrh_h{"$val"} ) {
		    $unrh_h{"$val"} = 0;
		}
		if ( exists $rh->{"error"} ) {
		    $unrh_h{"$val"} += 1;
		}
	    }
	    
	    if ( exists $rh_h{$rh->{"content"}} ) {
		$rh_h{$rh->{"content"}} = $rh_h{$rh->{"content"}} + 1;
		    #	if ( exists $opts{d} ) {
		    #	    printf "DUPLICATE \n";
		    #	    printf "rsync_history: %s = %d\n",
		    #	    $rh->{"content"}, $rh_h{$rh->{"content"}};
	            #   }
	    }
	    else {
		$rh_h{$rh->{content}} = 1;
	    }

	    # if ( exists $rh->{"error"} ) { 
	    #     printf "%s : ", $rh->{"content"};
	    #     printf "Error %i\n", $rh->{"error"};
	    # }
	}

	my @ds = ();
	for my $ho ( sort (keys %unrh_h) ) {
	    push @ds, [$ho, ($unrh_h{$ho} > 0 ? "Yes" : "No" )];
	}
	$data{$rcName}{DataSources} = \@ds;

    }

    return \%data;
} # getData



1;
