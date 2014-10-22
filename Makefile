DEFAULT: _build _build/vendor.js _build/css/all.css _build/compiled.js _build/fonts
	# yay

watch:
	watchman watch src
	echo '["trigger", "src", { "name": "remake", "expression": ["pcre", "\\\.(css|coffee)$$"], "chdir": "..", "command": ["make"] }]' | watchman -j

_build:
	mkdir -p $@

_build/vendor.js: vendor/jquery.min.js vendor/typeahead.js
	cat $^ > $@

_build/fonts: vendor/ratchet/fonts
	(cd _build; ln -s ../$^)

_build/css/all.css: vendor/ratchet/css/ratchet.css vendor/ratchet/css/ratchet-theme-ios.css src/ui/css/*.css
	mkdir -p $@
	cat $^ > $@

_build/js/.built: vendor/*.coffee src/*.coffee src/*/*.coffee
	coffee -o _build/js -m -c $^
	touch $@

_build/compiled.js: _build/js/.built
	mapcat _build/js/*.map -j _build/compiled.js -m _build/compiled.map


zip: _build
	(cd platforms/chrome; zip -r ../../_build/hindsight-for-chrome.zip background.html background.js css sdk/fonts images inject js manifest.json popup.html sdk/css/all.css sdk/compiled.js sdk/compiled.map sdk/vendor.js)
