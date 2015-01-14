dc_scraper
==========
http://www.dcinside.com scraper

DC inside 특정 갤러리에 접속하여 게시물 목록을 얻어온 뒤, 게시글을 하나씩 읽어 DB에 넣는 스크랩퍼

# 저작권
The Artistic License 2.0

LICENSE 파일 참조.

# 요구사항
* Perl 5.10+
 * DBI
 * DBD::mysql
 * HTML::TreeBuilder::LibXML
 * Web::Scraper
 * LWP::UserAgent
 * 기타 등등...
* MySQL or MariaDB

# 사용 방법
1. SQL 테이블 생성
2. libxml.pl 파일의 Shebang 확인(기본값은 #!/usr/bin/env perl ), 실행권한 주기(chmod u+x libxml.pl)
3. ./libxml.pl
 1. 주기적인 실행을 원하는 경우 kill_dizitown.sh 스크립트 실행. 6~11초 간격으로 실행됨.


# 주의사항
1. 한 번에 한 갤러리만 긁어올 수 있음.
 1. 또한, 갤러리 하나 당 DB 테이블 하나 필요
 1. DB 테이블 명은 'dc_갤러리명' 형식으로 생성해야 함.
1. 현재 소스는 자전거 갤러리만 긁어올 수 있게 되어 있음.
1. 갤러리 변경을 원할 경우엔, $gal_name 변경 필요.
1. 여러 갤러리를 긁어오고 싶으면 대응하는 DB 테이블 생성을 먼저하고, 실행할 때 32번째 줄 gal_name 입력 부분을 실행할 때 인자로 받아서 넣도록 하면 됨. 그 다음 kill_dizitown.sh 에서 갤러리 명을 인자로 넣어서 실행하는 방식으로... 하면 될까? 나도 모르겠다. 다음 항목의 기능 때문에 안될 수도...
1. libxml.pl 을 직접 실행할 경우, './libxml.pl 1 300' 과 같은 방식으로 실행하면 300번째 페이지에서 1페이지(가장 최근 페이지)까지의 글을 가져오게 됨. 이미 저장된 글은 다시 읽지 않음.
