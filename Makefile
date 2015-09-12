BUILD=_build
CRX=$(BUILD)/chromeExtension

# crx

$(CRX): $(CRX)/background.js $(CRX)/all.css $(CRX)/fonts
	rsync -rupE resources/chromeExtension/ $@
	cp -R vendor/ratchet/css/fonts $@

$(CRX)/background.js: src/chromeExtension/background.jsx
	mkdir -p $(@D)
	browserify $^ -t [ babelify --sourceMaps both --compact false ] --outfile $@ --debug

watch:
	watchify src/chromeExtension/background.jsx -t [ babelify --sourceMaps both --compact false ] --outfile $(CRX)/background.js --debug

$(CRX)/fonts: vendor/ratchet/css/fonts
	rsync -rupE  $^/ $@

$(CRX)/all.css: vendor/ratchet/css/ratchet.min.css src/*/*/*.css src/*/*.css
	cat $^ > $@


# test pages

designs:
	budo testPages/designTestPage.jsx:index.js --live -- -t babelify

review:
	budo testPages/reviewTestPage.jsx:index.js --live -- -t babelify



# ...

# _build/hindsight-for-chrome.zip: _build/hindsight-for-chrome
# 	(cd $^; zip -r ../hindsight-for-chrome.zip .)
#
# publish:
# 	https://github.com/jonnor/chrome-webstore-deploy

# watch:
# 	watchman watch .
# 	watchman -- trigger . $(PROJ) '*' -- make
#
# export PATH:=/usr/local/bin:$(PATH)
# BIN=./node_modules/.bin
#
# node_modules/.bin:
# 	npm install
##
# watch: node_modules/.bin
# 	watchman watch src
# 	echo '["trigger", "src", { "name": "remake", "expression": ["pcre", "\\\.(css|coffee)$$"], "chdir": "..", "command": ["make"] }]' | watchman -j
