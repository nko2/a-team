COFFEE=../node_modules/.bin/coffee
STYLUS=../node_modules/.bin/stylus

public/css.css:
	$(STYLUS) -c `find app -name \*.stylus`
	cat `find app -name \*.cssus` > $@

public/app.js:
	$(COFFEE) -c `find app -name \*.coffee`
	cat `find app -name \?\*.js` > $@

server: public/app.js public/css.css
	$(COFFEE) -c `find server -name \*.coffee`
	cd server && node server.js

test:
	@echo "populate me"

.PHONY: test
