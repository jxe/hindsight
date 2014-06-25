DEFAULT:
	coffee -j site/compiled.js -c doc/*.coffee widgets/*/*.coffee site/*.coffee

watch:
	coffee -j site/compiled.js -cw doc/*.coffee widgets/*/*.coffee site/*.coffee
