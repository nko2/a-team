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

public/app.js: public/jquery.js
	$(COFFEE) -c `find app -name \*.coffee`
	cat `find app -name \?\*.js` > $@

server: public/app.js public/css.css files
	$(COFFEE) -c `find server -name \*.coffee`
	cd server && node server.js

clean:
	rm -f public/app.js public/css.css

test:
	@echo "populate me"

.PHONY: test server
