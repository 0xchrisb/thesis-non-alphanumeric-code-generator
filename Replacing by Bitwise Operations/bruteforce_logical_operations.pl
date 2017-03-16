#!/usr/bin/perl
#Array with all non-alphanumeric characters
my @charset = ('!','"','$','%','&','/','(',')','=','{','[',']','}','\\','`',',',';','.',':','-','_','+','*','~','#','\'','@','<','>','|','?','^',' ');

#two loops to get all possible combinations of non-alphanumeric characters
foreach(@charset) {
	$first = $_;
	foreach(@charset) {
		#only printed if the result of the combination is alphanumeric and inside the ASCII range
		#"&" AND
		print (($first & $_)."\t('$first'&'".$_."');\n") if(($first & $_) =~ /^[a-zA-Z0-9]+$/ );
		#"|" OR
		print (($first | $_)."\t('$first'|'".$_."');\n") if(($first | $_) =~ /^[a-zA-Z0-9]+$/);
		#"^" XOR
		print (($first ^ $_)."\t('$first'^'".$_."');\n") if(($first ^ $_) =~ /^[a-zA-Z0-9]+$/);
	}
}
