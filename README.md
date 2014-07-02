dc_scraper
==========
http://www.dcinside.com scraper

DC inside 특정 갤러리에 접속하여 게시물 목록을 얻어온 뒤, 게시글을 하나씩 읽어 DB에 넣는 스크랩퍼

# 요구사항
* Perl 5.10+
* MySQL

# 사용 방법
1. SQL 테이블 생성
2. libxml.pl 파일의 Shebang 확인(기본값은 #!/usr/bin/env perl ), 실행권한 주기(chmod u+x libxml.pl)
3. ./libxml.pl
