#!/usr/bin/perl
use LWP::Simple;
use utf8;
use XML::Parser::Lite;
binmode(STDOUT, ":encoding(utf8)");
$ctt = get("http://feed.smzdm.com");
#print $ctt;

$url = "http://feed.smzdm.com";
if($ctt = fetchContent($url)){
	$p1 = new XML::Parser::Lite;
	$p1 -> setHandlers(
		Start => sub {shift; print "Start : @_\n";},
		Char => sub {shift; print "Char: @_\n";},
		End => sub {shift; print "End: @_\n";}
	);
	$p1 -> parse($ctt);
}

sub fetchContent(){
	my ($url) = @_;	
	my $ctt = get($url);
	if(defined $ctt){
		return $ctt;
	}else{
		return 0;
	}
}
