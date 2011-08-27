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
	cat app/models/cue.js `find app -name \?\*.js` > $@

server: 
	coffee server/server.coffee

clean:
	rm -f public/app.js public/css.css

test:
	@echo "populate me"

.PHONY: test server
