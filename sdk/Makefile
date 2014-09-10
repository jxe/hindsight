DEFAULT: _build _build/vendor.js _build/all.css _build/compiled.js
	# yay

_build:
	mkdir -p $@

_build/vendor.js: vendor/jquery.min.js vendor/typeahead.js
	cat $^ > $@

_build/all.css: vendor/ratchet/css/ratchet.css vendor/ratchet/css/ratchet-theme-ios.css css/*.css
	cat $^ > $@

_build/js/.built: vendor/*.coffee src/*/*.coffee
	coffee -o _build/js -m -c $^
	touch $@

_build/compiled.js: _build/js/.built
	mapcat _build/js/*.map -j _build/compiled.js -m _build/compiled.map

watch:
	watchman watch $(shell pwd)
	watchman -- trigger $(shell pwd) remake '*.js' '*.css' '*.coffee' -- sh -c make
