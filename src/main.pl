#!/usr/bin/perl
use Net::SMTP;
use Mail::Mailer;
use Data::Dumper;
use Encode;
use LWP::Simple;
use utf8;
use XML::Parser::Lite;
use XML::Simple;
#binmode(STDOUT, ":decoding(utf8)");
#binmode(STDOUT, ":encoding(utf8)");
#print $ctt;
$conf = "conf.xml";
$confxml = XML::Simple -> new();
$ref = $confxml -> XMLin($conf);
#print Dumper ${$ref}{'channel'}{'item'}[0];
$url = ${$ref}{'url'};
$email = ${$ref}{'email'};
$time = ${$ref}{'time'};

$smtpServer = ${$ref}{'smtpserver'};
$smtpUser = ${$ref}{'smtpuser'};
$smtpto = ${$ref}{'email'};
$smtpsbj = ${$ref}{'smtpsbj'};
$smtpPass = ${$ref}{'smtppass'};
$smtpname = ${$ref}{'smtpname'};
$smtpPort = 25;

#@keywords = encode("UTF-8", ${$ref}{'keywords'});
$keywords =  ${$ref}{'keywords'}{'key'};
@keywords ;
for($i = 0; $i < @{$keywords}; $i ++){
	#push @keywords, encode('UTF-8', ${$keywords}[$i]);
	push @keywords, ${$keywords}[$i];
}
$search = (join('|', @keywords));
$search = Encode::encode('UTF-8', $search);
while(1){
	if($ctt = fetchContent($url)){
	#	$p1 = new XML::Parser::Lite;
	#	$p1 -> setHandlers(
	#		Start => sub {shift; print "Start : @_\n";},
	#		Char => sub {shift; print "Char: @_\n";},
	#		End => sub {shift; print "End: @_\n";}
	#	);
	#	$p1 -> parse($ctt);
		$ctt = Encode::encode("UTF-8", $ctt);
		$xml = XML::Simple -> new();
		$ref = $xml -> XMLin($ctt);
		#$ref = $xml -> XMLin("feed.xml");
		#print Dumper ${$ref}{'channel'}{'item'}[0];
		$len = scalar(@{${$ref}{'channel'}{'item'}});
		@shootArr; 
		for($i = 0; $i < $len; $i ++){
			my $title = ${$ref}{'channel'}{'item'}[$i]{'title'};
			my $link = ${$ref}{'channel'}{'item'}[$i]{'link'};
			# This is A bug!!!!
			print "title: " . $title."\n";
			if($i > 0){
			#	$title = decode("UTF-8", $title);
			}else{
			#	$title = decode("UTF-8", $title);
			}
			print Dumper $title;
			if($title =~ /$search/){
				push @shootArr, $title . " Link: $link";
	#		print "title: ". ${$ref}{'channel'}{'item'}[$i]{'title'}."\n";
	#		#print "description: ".${$ref}{'channel'}{'item'}[$i]{'description'}."\n";
	#		print "content: ".${$ref}{'channel'}{'item'}[$i]{'content:encoded'}."\n";
			}
		}
		if(@shootArr > 0){
			$mailContent = join("\n", @shootArr);
			$mailContent = Encode::encode('iso-8859-1', $mailContent);
			mailto($mailContent);
		}
	}
	sleep $time;
}

sub fetchContent{
	my ($url) = @_;	
	my $ctt = get($url);
	if(defined $ctt){
		return $ctt;
	}else{
		return 0;
	}
}
sub mailto{

	my ($msg) = @_;
	$smtp = Net::SMTP->new($smtpServer,Port=>$smtpPort, Timeout=>10, Debug=>1);
	$smtp -> auth($smtpUser, $smtpPass);
	
	$smtp->mail($smtpUser);
	$smtp->to($smtpto);
	
	$smtp->data();
	$smtp->datasend('From: '.$smtpname. "<$smtpUser>\n");
	$smtp->datasend("Subject: $smtpsbj\n");
	$smtp->datasend("To: $smtpto\n");
	$smtp->datasend("\n");
	$smtp->datasend("$msg\n");
	$smtp->dataend();
	
	$smtp->quit;
}
