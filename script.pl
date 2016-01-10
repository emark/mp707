#!/usr/bin/env perl -w

use strict;
use warnings;
use utf8;

use DBIx::Custom;
use YAML::XS 'LoadFile';

my $config = LoadFile('config.yaml');

my $src_file = 'BM1707.temp';
my @src_data = ();

my $dbi = DBIx::Custom->connect(
   dsn => "dbi:mysql:database=$config->{database}",
   user => $config->{user},
   password => $config->{pass},
   option => {mysql_enable_utf8 => 1}
);

open (SOURCE,"< $src_file") || die "Can't open file: $src_file";
@src_data = split(' ',substr(<SOURCE>,,23));
close SOURCE;

foreach my $key(@src_data){
	my($name,$value) = split('=',$key);
	$value=~s/(,)/./; #Change separate
	
	print "SENSOR:$name\tVALUE:$value\n";
	#push @data, {name => $name, value => $value}; Feature for multiple insert ORM

	$dbi->insert(
		{
			name => $name,
			value => "$value",
		},
		ctime => 'sysdate',
		table => 'temp',
	);
};

1;

