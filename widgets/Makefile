DEFAULT: vendor.js all.css compiled.js
	# yay

vendor.js: vendor/jquery.min.js vendor/typeahead.js
	cat $^ > $@

all.css: vendor/ratchet/css/ratchet.css vendor/ratchet/css/ratchet-theme-ios.css widgets.css
	cat $^ > $@

compiled.js: */*.coffee
	coffee -mj $@ -c $^

watch:
	watchman watch $(shell pwd)
	watchman -- trigger $(shell pwd) remake '*.js' '*.css' -- sh -c make
	watchman -- trigger $(shell pwd) coffee '*.coffee' -- sh -c make
