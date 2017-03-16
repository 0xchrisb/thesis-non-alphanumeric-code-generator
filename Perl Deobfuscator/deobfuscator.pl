#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;
my $modpath = "/etc/apache2/modsecurity2/";	#path to ModSecurity regular expressions

my $report;
my %options=();
#Parameter handling
getopts("hj:ln:s:", \%options);
usage($modpath) if defined $options{h};	
$report.= "====================$/Payload$/====================$/$options{s}.$/" if defined($options{s}) or usage($modpath);

#Create folder structure
create_directory();

#Save file
my $filename = random_filename();
while(-e $filename) {
	$filename = random_filename();
}

open(FILE,">./log/$filename") or die("Could not create a new file\n");
print FILE $options{s};
close(FILE);

#Deparse
my $deparse = `perl -MO=Deparse ./log/$filename`;
$report.= "====================$/Deobfuscated$/====================$/".$deparse;


#Analyse with modsecurity rules
my $possibleinjections = 0;
opendir(DIR,$modpath);

$report .= "====================$/Matched RegEx$/====================$/";
foreach (readdir(DIR)) {
	next if ($_ =~ /^\.|\.\.$/);	#skip if file is . or ..
	open(IN,"<".$modpath.$_) or die("Could not open $_$/");
	while(<IN>) {
		if($_=~ /^SecRule (.+) "(.+)" \\$/ && $_ !~ /ecmascript /) { # skip if line is not a rule
			my $regex = $2;
			if($deparse =~ /$regex/) {	#found a injection
				$report .= $regex.$/;
				$possibleinjections++;
			}
		}
	}
	close(IN);
}
closedir DIR;
$report .= "$/$/Total injections: ".$possibleinjections.$/;
$report .= "====================$/";

#move payload to safe or malicious and save a report
my $path;
$path = "malicious" if($possibleinjections != 0) or $path = "safe";

open(FILE,">./log/$path/$filename") or die("Could not create a new file\n");
print FILE $options{s};
close(FILE);
unlink("./log/".$filename);

open(FILE,">./log/reports/$filename.log") or die("Could not create a new file\n");
print FILE $report;
close(FILE);

#function to create the folder structure
sub create_directory {
	my @dir = ('./log', './log/safe', './log/malicious', './log/reports');
	foreach(@dir) {
		unless(-d $_) {
			mkdir $_ or die("could not create $_");
		}
	}
}

#random filename to avoid a collision
sub random_filename {
	my @chars=('a'..'z','A'..'Z','0'..'9');
	my $random_string = time."_";

	$random_string.=$chars[rand @chars] foreach (1..20);
	return $random_string;
}

#information about the script
sub usage{
	my $modpath = shift;
	print 	"Usage: $0 -s <Obfuscated code>$/$/This script transforms obfuscated perl code back using B::Deparse$/".
		"and analyses the code by using rules from ModSecurity.$/".
		"Configuration:$/\t\tModSecurity rules path: $modpath$/";
	exit;
}
