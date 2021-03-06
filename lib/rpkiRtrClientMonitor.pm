package rpkiRtrClientMonitor;

use Exporter;
@EXPORT  = qw( rpkiRtrClientMonitor_getData );
$VERSION = '0.1';

use strict;
use DateTime;

# my %config = (
#     hosts => [
# 	{ name     => "router1",
#           location => "127.0.0.1:16161",
# 	  password =>  "v2user",
# 	},
#     ],
#     );


sub rpkiRtrClientMonitor_getData {
    my ($sources_p) = @_;
    
    my $debug = 0;
    
    my %data = ();
    my @dsources = ();

    foreach my $source ( @{$sources_p->{hosts}} ) {
	if ( ! exists $source->{hist} ) {
	    $source->{hist}{adds}    = 0;
	    $source->{hist}{deletes} = 0;
	}
	my %src_h = ();

	# XXX as OO this will make more sense
	my $dt =  DateTime->now;
	my $dtstring = sprintf "%s", $dt;
	if ( !exists $source->{start_date} ) {
	    $source->{start_date} = $dtstring;
	}
	$source->{last_date} = $dtstring;
	
	$src_h{name}       = $source->{name};
	$src_h{location}   = $source->{location};
	$src_h{start_date} = $source->{start_date};
	$src_h{last_date}  = $source->{last_date};
	
	my $cst = get_cache_server_table($source->{location}, 
					 $source->{password});

	for my $i (keys %$cst) {
	    $src_h{source} = $i;
	    if ( $cst->{$i}{"rpkiRtrCacheServerConnectionStatus"} =~ /up/ ) {
		$src_h{status} = "UP";
	    }
	    else {
		$src_h{status} = "DOWN";
	    }
	    if ($debug) {
		printf "\t%s  :  Status = %s\n", $i, 
                       $cst->{$i}{"rpkiRtrCacheServerConnectionStatus"}
	    }
	}

	my $pot = get_prefix_origin_table($source->{location}, 
					  $source->{password});

	my @pota = (keys %$pot);
	$src_h{current_prefixes} = $source->{current_prefixes} = ($#pota + 1);

	if ($debug) {
	    printf "Prefix/ASNs:\n";
	    printf "\tCurrent : %i\n", ($#pota + 1);
	}

	do_add_deletes($source->{old_pot}, $pot, \%{$source->{hist}});
	
	$src_h{prefixes_added}   =  $source->{hist}{"adds"};
	$src_h{prefixes_deleted} =  $source->{hist}{"deletes"};

	if ($debug) {
	    my $what = \%src_h;
	    my $refstring = ref $what;
	    printf "type of %s is %s\n", "src_h", ref \%src_h;
	    printf "\tSince %s\n", $src_h{last_date};

	    printf "\tAdded   : %i\n", $source->{hist}{"adds"};
	    printf "\tDeleted : %i\n", $source->{hist}{"deletes"};
	    printf "\n=============================\n";
	}
	
	$source->{old_pot} = $pot;
	push @dsources, \%src_h;
    }
    $data{sources} = \@dsources;
    
    return \%data;
}

# *********** PROCS PROCS PROCS PROCES PROCs ****************

sub do_add_deletes  {
    my($old, $new, $histp) = @_;

    if ( ! $old ) {
	my @cpot = (keys %$new);
	$histp->{"adds"} = ($#cpot + 1);
	$histp->{"deletes"} = 0;
    }
    else {
	# intersect
	my @newlist = keys %$new;
	my @oldlist = keys %$old;
	my %temph = ();
	foreach my $element (@newlist, @oldlist) { $temph{$element}++ }
	foreach my $element (keys %temph) {
	    if ( $temph{"$element"} == 1 ) {
		if    ( exists $new->{"$element"} ) { $histp->{"adds"}    += 1; }
		elsif ( exists $old->{"$element"} ) { $histp->{"deletes"} += 1; }
		else  { printf "Warn: $element doesnt exist?\n"; }
	    }
	}
    }
}


# sub snmpwalk {
#     my($start, $stop) = @_;
#     my $SW_H;
#     my %table;
    
#     open( $SW_H, 
# 	  "snmpwalk -v 2c -c $opts{p} -C E $stop $opts{h} $start |" ) ||
# 	die "Unable to open snmpwalk: $@\n";

#     while (my $line = <$SW_H>) { 
# 	mprint $line;
# 	if ( $line =~ /^.*::([^.]+)\.([^.]+)\."(.*)"\.(\d+)\s+=\s+(.*)/ ) {
# 	    $table{"$2::$3::$4"}{"$1"} = $5;
# 	    printf "table\{$2::$3::$4\}\{$1\} = $5\n";
# 	}
	
#     }

#     close $SW_H;

#     for my $i (keys %table) {
# 	printf "Row $i\n";
#     }
# }

    
sub get_cache_server_table {
    my ($host, $pass) = @_;

    my $start = join(".", (1, 3, 6, 1, 2, 1, 218, 1, 2));
    my $stop = join(".", ( 1, 3, 6, 1, 2, 1, 218, 1, 3));

    my $SW_H;
    my %table;
    
    open( $SW_H, 
	  "snmpwalk -v 2c -c $pass -C E $stop $host $start |" ) ||
	die "Unable to open snmpwalk: $@\n";

    while (my $line = <$SW_H>) { 
	# mprint $line;
	if ( $line =~ /^.*::([^.]+)\.([^.]+)\."(.*)"\.(\d+)\s+=\s+(.*)/ ) {
	    $table{"$2::$3::$4"}{"$1"} = $5;
#	    printf "table\{$2::$3::$4\}\{$1\} = $5\n" if ($debug);
	}
	
    }

    close $SW_H;

    return \%table;
}

    
sub get_prefix_origin_table {
    my ($host, $pass) = @_;

    my $start = join(".", (1, 3, 6, 1, 2, 1, 218, 1, 4));
    my $stop = join(".", ( 1, 3, 6, 1, 2, 1, 218, 1, 5));

    my $SW_H;
    my %table;
    
    open( $SW_H, 
	  "snmpwalk -v 2c -c $pass -C E $stop $host $start |" ) ||
	die "Unable to open snmpwalk: $@\n";

    while (my $line = <$SW_H>) {
	my $index = "";
	my $col   = 0;
	my $val   = 0;
	# mprint $line;
	#                   column. addrtype.  addr.  mipref.mapref .asn  
	if ( $line =~ /^.*::([^.]+)\.([^.]+)\."(.*)"\.(\d+)\.(\d+)\.(\d+).(\d+)\s+=\s+Gauge32:\s+(\d+)/ 
	    ) {
	    $col = $1;
	    $val = $8;
	    $index = "$2::$3::$4::$5::$6";
#	    if ( exists $table{"$index"} ) {
#		printf "Warning: Dublicate : prefix orgin table : \'$index\'\n";
#	    }
	}
	elsif ( $line =~ /^.*\.218\.1\.4\.1\.(\d+)\.(\d+)\.([\d.]+)\.(\d+)\.(\d+)\.(\d+)\.(\d+)\s+=\s+Gauge32:\s+(\d+)/
	    ) {
	    $col = $1;
	    $val = $8;
	    my $prefix  = "$2::";
	    my $postfix = "::$4::$5::$6::$7";
	    my $addr    = $3;
	    my @aa = split /\./, $addr;
	    if ( 4 == shift @aa ) {
		$addr = sprintf "%d", $aa[0];
		for(my $i = 1; $i <= $#aa; $i++) {
		    $addr = "$addr" . sprintf ".%d", $aa[$i];
		}
	    }
	    else {
		$addr = sprintf "%02x", $aa[0];
		for(my $i = 1; $i <= $#aa; $i++) {
		    $addr = "$addr" . sprintf ":%02x", $aa[$i];
		}
	    }
	    $index = $prefix . $addr . $postfix;
	}
#	if ( exists $table{"$index"} ) {
#	    printf "Warning: Dublicate : prefix orgin table : \'$index\'\n";
#	}
	if ( "" ne "$index" ) {
	    $table{"$index"}{"$col"} = $val;
	    # printf "table{$2::$3::$4::$5::$6}{\"$col\"} = $val\n";
	}
    }

    close $SW_H;

    return \%table;
}

    
sub oid_sort {
    my $count = 0;
    while ( $count <= @$a && $count <= @$b) {
	if    ($a->[$count] == $b->[$count]) { }
	elsif ($a->[$count] < $b->[$count])  { return -1; }
	elsif ($a->[$count] > $b->[$count])  { return  1; }
	$count++;
    }
    if    ( $count == @$a ) { return  1; }
    elsif ( $count == @$b ) { return -1; }

    return 0;
}

1;
