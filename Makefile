DEFAULT:
	echo 'yo'

zip:
	mkdir -p _build
	(cd crx; zip -r ../_build/hindsight-for-chrome.zip .)
