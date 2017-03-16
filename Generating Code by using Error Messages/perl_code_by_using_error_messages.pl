#!/usr/bin/perl
$__='';
#Error messages needed to replace a-z
eval("_=_");$__.=$@;
eval("{");$__.=$@;
eval("_/\$[");$__.=$@;
eval("a a");$__.=$@;
eval('"');$__.=$@;

$__ =~ s/\n//g;		#remove newlines
$__ =~ s/eval \d*//g;	#remove eval xx
$__.=uc($__);		#all characters to upper case
@_ = $__=~ /./g;	#split char by char into array


#numbers 1,2,3,4,5,6,7,8,9,0
$___ = $$/$$;		#$$ is the current process number
$____ = $___+$___;
$_____ = $____+$___;
$______ = $____ * $____; 
$_______ = $______ + $___;
$________ = $____ * $_____;
$_________ = $________ + $___;
$__________ = $____ * $______ ;
$___________ = $__________ + $___;
$____________ = $___ - $___;

my $inj;
#The code to be transformed is located in exploit.txt
open(IN,"<exploit.txt") or die("Place your code in exploit.txt\n");
while(<IN>) {
	$inj.=$_;	#Reading the content of the file and appending to $str
}
close(IN);

print "\$/='";	#first part of the payload
foreach($inj=~/./g) {	#loop through all characters
	if($_ =~ /[A-Za-z]/ && $__ =~ m/$_/g ) {	#if character is a-zA-Z it is replaced
		print '@_['.asInt(pos($__)-1).'].';	#array position is searched and printed
		pos($__)  = 0;				#reset position
	} elsif ($_ =~ /[0-9]/) {			#if character is a number
		print asInt($_).".";
	} elsif($_ eq "\\") {				
			print '"\\\\\\\\".';		#\ is encoded to \\\\
	} elsif($_ eq "'") {
			print '"\\\'".';		#' is encoded to \\'
	} elsif($_ eq '"') {
			print '"\\"".';			#" is encoded to \"
	} elsif($_ eq '$') {
			print '"\\$".';			#$ is encoded to \$
	} else {
		print "\"$_\".";			#character was non-alphanumeric
	}

}
print "\"\"';";	#end of the payload

#generation of all needed error messages in a non-alphanumeric way (same as in line 2 - 13)
print "\$___ = '{';''=~('(?{'.('^'^';').('+'^']').('?'^'^').(','^'\@').'(\\'_=_\\');\$__.=\$\@;'.('^'^';').('+'^']').('?'^'^').(','^'\@').'(\$___);\$__.=\$\@;\$___=\\'_/\$[\\';'.('^'^';').('+'^']').('?'^'^').(','^'\@').'(\$___);\$__.=\$\@;\$___=\\''.(\'^\'^\'?\').' '.(\'^\'^\'?\').'\\';'.('^'^';').('+'^']').('?'^'^').(','^'\@').'(\$___);\$__.=\$\@;\$___=\\'\"\\';'.('^'^';').('+'^']').('?'^'^').(','^'\@').'(\$___);\$__.=\$\@;\$__ =~ '.(\'_\'^\',\').'/\\\\'.('\@'^'.').'//'.(\']\'^\':\').';\$__ =~ '.(\'_\'^\',\').'/'.(\'^\'^\';\').(\'+\'^\']\').(\'?\'^\'^\').(\',\'^\'\@\').' \\\\'.(\'^\'^\':\').'*//'.(\']\'^\':\').';\$__.='.(\'.\'^\'[\').(\'^\'^\'=\').'(\$__);\@_ = \$__=~ /./'.(\']\'^\':\').';";
#numbers
print '$___ = $$/$$;$____ = $___+$___;$_____ = $____+$___;$______ = $____ * $____; $_______ = $______ + $___;$________ = $____ * $_____;$_________ = $________ + $___;$__________ = $____ * $______ ;$___________ = $__________ + $___;$____________ = $___ - $___;';
#execution of the payload
print "'.('^'^';').('+'^']').('?'^'^').(','^'\@').'('.('^'^';').('+'^']').('?'^'^').(','^'\@').'(".'$/));'."})');";

#function to replace numbers with the correspondending non-alphanumeric representation
sub asInt {
	my @numbers = ('$____________', '$___', '$____', '$_____', '$______', '$_______', '$________', '$_________', '$__________', '$___________');
	my $out;
	my $int = shift;
	my @chars = split(//,$int);
	my $length = @chars;

	for(my $i=0;$i<$length;$i++) {	
		$out.= $numbers[$chars[$i]];
		$out .= '.' if($i!=$length-1);
	}
	return $out;
}
