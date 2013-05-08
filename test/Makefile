test: db
	env VIMRUNTIME=../ vim -R --noplugin -u NONE inhe.cpp -S test.vim
db:
	cxxtags inhe.cpp -o inhe.db
	cxxtags_merger db inhe.db
clean:
	rm -rf db inhe.db test.log
