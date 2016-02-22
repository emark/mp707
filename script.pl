#!/usr/bin/env perl -w

use strict;
use warnings;
use utf8;

use DBIx::Custom;
use YAML::XS 'LoadFile';

my $config = LoadFile('config.yaml');

chdir('logs');
my @src_files = <*.dat>;
my @src_data = ();

print @src_files;
my $src_file;
exit;
my $dbi = DBIx::Custom->connect(
   dsn => "dbi:mysql:database=$config->{database}",
   user => $config->{user},
   password => $config->{pass},
   option => {mysql_enable_utf8 => 1}
);

open (SOURCE,"< $src_file") || die "Can't open file: $src_file";
@src_data = split(' ',substr(<SOURCE>,,23));
close SOURCE;

print localtime(time)."\n";
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
		ctime => 'ctime',
		table => 'temp',
	);
};

1;
