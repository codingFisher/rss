use Net::SMTP;
use Mail::Mailer;
use Data::Dumper;
use Encode;
use LWP::Simple;
use utf8;
use XML::Parser::Lite;
use XML::Simple;
$conf = "conf.xml";
$confxml = XML::Simple -> new();
while(1){
	$ref = $confxml -> XMLin($conf);
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
	
	$keywords =  ${$ref}{'keywords'}{'key'};
	@keywords = ();
	for($i = 0; $i < @{$keywords}; $i ++){
		push @keywords, ${$keywords}[$i];
	}
	$search = (join('|', @keywords));
	$search = Encode::encode('UTF-8', $search);
	
	if($ctt = fetchContent($url)){
		$ctt = Encode::encode("UTF-8", $ctt);
		$xml = XML::Simple -> new();
		$ref = $xml -> XMLin($ctt);
		$len = scalar(@{${$ref}{'channel'}{'item'}});
		@shootArr = (); 
		for($i = 0; $i < $len; $i ++){
			my $title = ${$ref}{'channel'}{'item'}[$i]{'title'};
			my $link = ${$ref}{'channel'}{'item'}[$i]{'link'};
			print "title: " . $title."\n";
			if($i > 0){
			}else{
			}
			if($title =~ /$search/){
				push @shootArr, $title . " Link: $link";
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
