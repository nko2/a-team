COFFEE=../node_modules/.bin/coffee
STYLUS=../node_modules/.bin/stylus

all: server

files:
	mkdir -p ../podcast_data

public/css.css:
	$(STYLUS) -c `find app -name \*.stylus`
	cat `find app -name \*.cssus` > $@

public/jquery.js:
	cp ../node_modules/jquery/dist/node-jquery.min.js $@

compile: 
	$(COFFEE) -c `find server -name \*.coffee`
	$(COFFEE) -c `find app -name \*.coffee`
	cat app/models/cue.js `find app -name \?\*.js` > $@

public/js/socket.io.js:
	node ../node_modules/socket.io-client/bin/builder.js
	cp ../node_modules/socket.io-client/dist/socket.io.js public/js

server: public/css.css files public/js/socket.io.js
	../node_modules/.bin/coffee server/server.coffee

clean:
	find app -name "*.js" -exec rm {} \;
	find server -name "*.js" -exec rm {} \;
	rm -f public/app.js public/css.css

test:
	@echo "populate me"

.PHONY: test server compile
