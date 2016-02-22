#!/usr/bin/env perl -w

use strict;
use warnings;
use utf8;

use DBIx::Custom;
use YAML::XS 'LoadFile';

my $config = LoadFile('config.yaml');
my @log = ();#Logfile data

chdir('logs');
my @src_files = <*.dat>;
my @src_data = ();

my $src_file;

my $dbi = DBIx::Custom->connect(
   dsn => "dbi:mysql:database=$config->{database}",
   user => $config->{user},
   password => $config->{pass},
   option => {mysql_enable_utf8 => 1}
);

my $file = 0;
while(<@src_files>){
	$file++;#Files counting
	push @log,"Parsing file: $_";

	open (SOURCE,"< $_") || die "Can't open file: $src_file";
	@src_data = <SOURCE>;
	close SOURCE;
	
	push @log,"Sensor readings: ".@src_data;
	my $line = 0;
	print "\e[H\e[J";#Clear display

	foreach my $key(@src_data){
		$line++;
		print "\e[K\e[H>Reading file $file:".@src_files."\t$line:".@src_data." lines\n";

		my ($date,$time) = split(' ',substr($key,1,19));
		my @sensors = split(' ',substr($key,23));
		
		foreach my $sensor(@sensors){
			my($name,$value) = split('=',$sensor);
			$value=~s/(,)/./; #Change separate
       		$dbi->insert(
	        	{
    	    	    datadate => $date,
        	    	datatime => $time,
	        	    name => $name,
    	        	value => "$value",
	        	},
		        ctime => 'ctime',
    	    	table => 'temp',
	    	);
		};
	};
};

open (LOGFILE,"> $config->{logfile}") || die "Can't open logfile: $config->{logfile}";
	foreach my $log(@log){
		print LOGFILE "$log\n";
	};
close LOGFILE;

1;
