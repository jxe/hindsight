DEFAULT: ../build ../build/vendor.js ../build/all.css ../build/compiled.js
	# yay

../build:
	mkdir -p $@

../build/vendor.js: vendor/jquery.min.js vendor/typeahead.js
	cat $^ > $@

../build/all.css: vendor/ratchet/css/ratchet.css vendor/ratchet/css/ratchet-theme-ios.css css/*.css
	cat $^ > $@

../build/compiled.js: vendor/*.coffee src/*.coffee
	coffee -mj $@ -c $^

watch:
	watchman watch $(shell pwd)
	watchman -- trigger $(shell pwd) remake '*.js' '*.css' '*.coffee' -- sh -c make
