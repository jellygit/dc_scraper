#!/bin/env perl 
use strict;
use warnings;
use DBI;
use autodie;
use LWP::UserAgent;
use HTML::TreeBuilder::LibXML;
use Web::Scraper; 
use URI;
use Data::Dump;
use Encode qw( decode encode );

################################################################################
# DB 접속 설정
my $dbh = DBI->connect(
	'dbi:mysql:database=jellydb',
	"$ENV{MYSQL_ID}",
	"$ENV{MYSQL_PW}",
	{ RaiseError => 1, PrintError => 0, AutoCommit => 0 },
);
################################################################################
# DC 갤러리 설정
my $gal_name = 'bicycle';
my $gal_l_url = 'http://gall.dcinside.com/board/lists/?id=' . $gal_name . '&page=';
my $gal_v_url = 'http://gall.dcinside.com/board/view/?id=' . $gal_name;


HTML::TreeBuilder::LibXML->replace_original();
my $ua = LWP::UserAgent->new( agent =>
	'Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0'
);
################################################################################
# 프로그램 시작
start( @ARGV );


sub start {
	my ( $start_page_num, $last_page_num ) = @_;
	$start_page_num ||= 1;
	$last_page_num  ||= 1;

	# 커맨드로 입력받은 last 페이지 번호를 현재 페이지 번호로 넣고 점점 줄여서 1페이지까지 불러들이기 위함
	for ( my $current_page_num = $last_page_num; $start_page_num <= $current_page_num; $current_page_num--) {
		print "current page : $current_page_num" . "\n";
		# 주소 + 페이지 번호 = $g_name

		my $list_url = $gal_l_url . $current_page_num;
		print "list_url $list_url\n";
		my $no_list = get_no($list_url);
		get_content($no_list);
	}
	$dbh->disconnect();
}

sub get_no {
	my ($url) = @_;

	my $scrape_no = scraper {
		process "td.t_notice", "no[]" => "TEXT";
	};

	my $res = $scrape_no->scrape( URI->new($url) );
	return \@{ $res->{no} };
}

sub get_content {
	my ($nos) = @_;

	for my $no ( @{$nos} ) {
		if ( $no =~ /(\d+)/ ) {
			my $f_url = $gal_v_url . "&no=" . $no;
			print $f_url . "\n";
			my $scrape_content = scraper {
				process "head > meta", "content[]" => '@content';
				process "div.s_write", "text" => "TEXT";
			};

			my $res = $scrape_content->scrape( URI->new($f_url) );
			my $result_string = $no . " : " . $res->{content}[7] . " " . $res->{content}[7] . " \t " . $res->{text} . "\n";
			print encode("utf-8", "$result_string") . "\n";
		}
	}

}
