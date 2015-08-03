hindsight
=========

This repo contains a chrome extension for reviewing the websites you visit.  It is made of several independent modules that are useful in their own right:

* In `src/usageTracker` you'll find a way of instrumenting chrome to record fine-grained usage data.  We track not only the minutes you spend on various websites (actually interacting with a relevant tab), but notifications and whether they bring you back, activities performed at the sites, time spent on other websites due to links from a feed from a main site, etc.  To instrument chrome, we call `LibUsage.activate()`, and thereafter calls like `LibUsage.getTimelineFor("https://facebook.com")` will return a JSON object of [Timeline](doc/Timeline.md) tracks called `usage`, `indirectUsage`, `notifications` etc.

* In `src/reasonComponents` you'll find a [react](https://facebook.github.io/react/) component for doing typeahead tagging about why a person would do a thing (i.e., their *reason* for doing the thing).  This currenly leverages a database of reasons kept in firebase, managed by the code in `src/collectiveExperience`.

* In `src/reviewComponent` you'll find [react](https://facebook.github.io/react/) widgets for reviewing activities in general, including web usage but also visits to venues, app usage, or whatever else you'd like to review.  The reviews include information about the reasons for use, whether those reasons were fulfilled by the activity in question, whether the investments involved seemed worth it, and whether the user continues to care about those reasons.  Reviews are pushed to a firebase database by the code in `src/collectiveExperience`.  The review consists of [Timeline](doc/Timeline.md) tracks (in addition to those record for `usage`, `indirectUsage`) that record `fulfillment` due to a website, `regret` about usage, and the `vision` of the user for their life.

* In `src/collectiveExperience/timelines.js` you'll find utilities for dealing with [Timeline](doc/Timeline.md) tracks, a simple JSON format for describing periodic, intermittent, observed, or regular events over time -- like web usage or regret.




## Getting started

Try `npm install` and `make` to build your own version of the extension.  If that isn't enough, let me know and I'll help you out.

The chrome extension can then be loaded as an unpacked extension in chrome by selecting the `_build/chromeExtension` directory.

To rebuild continuously, try `make watch`.
