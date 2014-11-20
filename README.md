hindsight
=========

A javascript SDK, including various widgets, for dealing with users' expectations when engaging with different URLs and websites and so on, and collecting information about whether they worked out.

The data model is documented at http://willandintent.org/cxp/.

See also the paper on Human Choicemaking at http://nxhx.org/Choicemaking/.


## Getting started

Make sure you have node+npm installed.  A simple "make" will install dependencies and build libhindsight.  The chrome extension can then be loaded as an unpacked extension in chrome by selecting the packages/chrome directory in the extensions screen, or you can start a webserver in the root directory and navigate to the test view at tests/review.html.

To rebuild continuously as you change the coffeescript files, first make sure you have homebrew, then type "brew install watchman" to install facebook watchman.  Then "make watch" to monitor files for changes and remake as needed.  
