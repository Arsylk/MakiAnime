#!bin/perl
use LWP::Simple;

#user agent
my $agent = "Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.114 Mobile Safari/537.36";
#browser config
my $browser = LWP::UserAgent->new();
$browser->agent($agent);
#output file
my $output = "/home/arsylk/%s.txt";
#used for quality (0 -> minimal) (-1 -> maximal)
my $q = 0;
#title normalized
$ARGV[0] =~ m{^.*\/(.*?)$};
my $title = $1;
$title =~ s{-sub$|-dub$}{}i;
$title = lc($title);
$output = sprintf($output, $title);
unlink $output;
open(my $fh, ">>", $output);

sub println {
	print $_[0]."\n";
}

sub bypass {
	$command = sprintf("python3.4 /home/arsylk/synced/getContent.py %s", $_[0]);
	return `$command`;
}

sub bypass_id {
	$command = sprintf("python3.4 /home/arsylk/synced/getEpisode.py %s", $_[0]);
	return `$command`;
}

sub rapid_quality {
	my $content = $browser->get($_[0])->content;
	my @quality = $content =~ m{"(https?:\/\/www\.rapidvideo\.com\/e\/.*?)"}g;
	return @quality[$q];
}

sub bypass_rapid {
	my $content = $browser->get($_[0])->content;
	if($content =~ m{<source.*?src=\"(.*?)\"}) {
		return $1;
	}
}

sub output {
	my $name = $_[0];
	$name =~ s{\s}{}g;
	print $fh sprintf("fdm.exe %s\n", $_[1]);
}


println $title;
println;

my $resp = bypass($ARGV[0]);
my @episodes = reverse($resp =~ m{<div.*?class="episode".*?data-value="(.*?)".*?>(.*?)</div>}g);
for($i = 0; $i < scalar @episodes; $i+=2) {
  if(@episodes[$i] =~ m{$ARGV[1]} || !$ARGV[1]) {
    println @episodes[$i];
    if(bypass_id(@episodes[$i+1]) =~ m{(https?:\/\/.*?)\|\|\|}) {
			my $url = $1;
			if($url =~ m{rapidvideo}) {
				$url = rapid_quality($url);
				println $url;
				my $direct = bypass_rapid($url);
				println $direct;
				output(@episodes[$i], $direct);
			}else {
				println $url;
				output(@episodes[$i], $url);
			}
		}else {
			println "\rEpisode not found";
		}
  }
}
close($fh);
