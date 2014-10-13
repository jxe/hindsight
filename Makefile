DEFAULT: _build _build/vendor.js _build/css/all.css _build/compiled.js _build/fonts
	# yay

_build:
	mkdir -p $@

_build/vendor.js: lib/vendor/jquery.min.js lib/vendor/typeahead.js
	cat $^ > $@

_build/fonts: lib/vendor/ratchet/fonts
	(cd _build; ln -s ../$^)

_build/css/all.css: lib/vendor/ratchet/css/ratchet.css lib/vendor/ratchet/css/ratchet-theme-ios.css lib/css/*.css
	mkdir -p $@
	cat $^ > $@

_build/js/.built: lib/vendor/*.coffee src/*.coffee src/*/*.coffee
	coffee -o _build/js -m -c $^
	touch $@

_build/compiled.js: _build/js/.built
	mapcat _build/js/*.map -j _build/compiled.js -m _build/compiled.map

watch:
	watchman watch $(shell pwd)
	watchman -- trigger $(shell pwd) remake '*.js' '*.css' '*.coffee' -- sh -c make

zip: _build
	(cd platforms/crx; zip -r ../../_build/hindsight-for-chrome.zip background.html background.js css sdk/lib/fonts images inject js manifest.json popup.html sdk/_build/all.css sdk/_build/compiled.js sdk/_build/compiled.map sdk/_build/vendor.js)
