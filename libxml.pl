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
use utf8;
use Thread qw ( async ) ;

################################################################################
# DB 접속 설정
my $dbh = DBI->connect(
	'dbi:mysql:database=$ENV{MYSQL_DB}',
	"$ENV{MYSQL_ID}",
	"$ENV{MYSQL_PW}",
	{
		RaiseError => 1,
		PrintError => 1,
		AutoCommit => 0,
		mysql_enable_utf8 => 1, 
	},
);
$dbh->do('SET NAMES utf8');
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
		my $nos = get_no($list_url);
		my @new_array = reverse( @{ $nos } );

		my $sql = "select no from dc_$gal_name order by no desc limit 0,1";
		my $sth = $dbh->prepare($sql);
		$sth->execute or die "$DBI::errstr\n";
		my $sql_no = $sth->fetchrow_array;
		unless ( $sql_no ) {
			$sql_no = 1;
		}


		#이미 저장 된 내용이나 공지는 배열에서 제거
		foreach my $index ( 0 .. $#new_array ) {
			print $index . "\t";
			if ( $new_array[$index] eq '공지' ) {
				print encode( "utf-8", "공지 삭제 $index\n" );
				delete $new_array[$index];
			} elsif ( $new_array[$index] <= $sql_no ) {
				print encode( "utf-8", "이미 있는거  $new_array[$index]\t$sql_no\n");
				delete $new_array[$index];
			} else {
				print encode( "utf-8", "$new_array[$index]\n");
			}

		}
		dd(@new_array);
		#완성된 배열을 컨텐츠 수집기에 넘김
		get_content( @new_array );
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
	my @nos = @_;
	my ( $no, $author, $title, $content, $sth );

	for $no ( @nos ) {
		if ( $no ) {
			if ( $no =~ /(\d+)/ ) {
				my $f_url = $gal_v_url . "&no=" . $no;
				print $f_url . "\n";
				my $scrape_content = scraper {
					process "head > meta", "content[]" => '@content';
					process "div.s_write", "text" => "TEXT";
				};

				my $res = $scrape_content->scrape( URI->new($f_url) );
				$title = $dbh->quote( $res->{content}[7] );# =~ s,(.*) - 자전거 갤러리,$1,g;
				$title =~ s,(.*) - 자전거 갤러리,$1,g;
				$author = $dbh->quote( $res->{content}[8] );
				$content = $dbh->quote( $res->{text} );

				my $sql = "insert into dc_$gal_name ( no, author, title, content ) values ( $no, $author, $title, $content )";
				print encode( "utf-8", $sql ) . "\n";
				$sth = $dbh->prepare( "$sql" , { "mysql_use_result" => 1} );
				$sth->execute or die "$DBI::errstr\n";
			}
		}
	}
	if ( $sth ) {
		$sth->finish();
	}
}

