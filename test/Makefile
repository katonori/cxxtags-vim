test: clean db
	vim -R --noplugin -u NONE inhe.cpp -S test.vim
db:
	cxxtags inhe.cpp -o inhe.db
	cxxtags_db_manager add db inhe.db
clean:
	rm -rf db inhe.db test.log
