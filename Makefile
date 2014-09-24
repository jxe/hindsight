DEFAULT:
	echo 'yo'

zip:
	mkdir -p _build
	(cd crx; zip -r ../_build/hindsight-for-chrome.zip background.html background.js css sdk/fonts images inject js manifest.json popup.html sdk/_build/all.css sdk/_build/compiled.js sdk/_build/compiled.map sdk/_build/vendor.js)
