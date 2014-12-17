export PATH:=/usr/local/bin:$(PATH)
BIN=./node_modules/.bin
JSC=_build/js
DIR=_build/libhindsight


############################
# for basic javascript lib #
############################

DEFAULT: node_modules/.bin $(DIR) $(DIR)/vendor.js $(DIR)/all.css $(DIR)/compiled.js $(DIR)/fonts
	# yay

node_modules/.bin:
	npm install

watch: node_modules/.bin
	watchman watch src
	echo '["trigger", "src", { "name": "remake", "expression": ["pcre", "\\\.(css|coffee)$$"], "chdir": "..", "command": ["make"] }]' | watchman -j

$(DIR):
	mkdir -p $@

$(DIR)/vendor.js: vendor/jquery.min.js vendor/typeahead.js
	cat $^ > $@

$(DIR)/fonts: vendor/ratchet/fonts
	cp -R $^ $@

$(DIR)/all.css: vendor/ratchet/css/ratchet.css vendor/ratchet/css/ratchet-theme-ios.css src/ui/css/*.css
	cat $^ > $@

$(JSC)/.built: vendor/*.coffee src/*.coffee src/*/*.coffee
	$(BIN)/coffee -o $(JSC) -m -c $^
	touch $@

$(DIR)/compiled.js: $(JSC)/.built
	$(BIN)/mapcat $(JSC)/*.map -j $(DIR)/compiled.js -m $(DIR)/compiled.map



########################
# for chrome extension #
########################

zip: $(DIR)
	(cd platforms/chrome; zip -r ../../_build/hindsight-for-chrome.zip .)

publish:
	# https://github.com/jonnor/chrome-webstore-deploy
