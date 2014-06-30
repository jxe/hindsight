DEFAULT:
	coffee -mj site/compiled.js -c doc/*.coffee widgets/*/*.coffee site/*.coffee

watch:
	coffee -mj site/compiled.js -cw doc/*.coffee widgets/*/*.coffee site/*.coffee
