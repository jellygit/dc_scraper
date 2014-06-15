#!/bin/env perl 
use strict;
use warnings;
use Web::Scraper; 
use URI;
use Data::Dump;
use Encode qw( decode encode );

my ( $start_page_num, $last_page_num ) = @ARGV;

my $page_scrap = scraper {
	process "div.s_write", 'td[]' => 'TEXT';
};

my $url;
for my $bbs_num ( $start_page_num .. $last_page_num ) {
	$url = "http://gall.dcinside.com/board/view/?id=bicycle&no=$bbs_num&page=1";
	my $res = $page_scrap->scrape( URI->new($url) );
	for my $txt ( @{ $res->{td} } ) {
		print encode( 'utf-8',  "$bbs_num : $txt\n----\n"  );
	}
	$res=undef;
}
