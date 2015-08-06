There are many ways to help out.


## Improving ratings on chrome

* Everyone: review websites, and report/fix problems you find.

* Data Designers:  Usage is currenly poorly summarized in the review. It’s just text that says “1 WEEKS @ 20 MINUTES/WEEK”.  What would be great is a graphic that shows usage over time, and has room for indirect usage, for notifications and whether they re-engaged you, etc.  To look at the raw data you have available, find the [Timeline](Timeline.md) tracks--usage, indirectUsage, and notifications--that are returned by [usageTracker/libusage](../src/usageTracker/libusage.js).  The first two are `bouts` timeline tracks, and the last is `events`.

* UX Designers: this is the alpha version of the review, built only with sliders, toggles, and a minimal typeahead input field, rather than more sophisticated widgets and flows.  It also could provide the user with a variety of feedback about what other people have said, etc, as they fill it out, and it currently doesn't.  The review consists of the typeahead at the top plus an expanding list of values inside which the user gets one of two forms depending on whether they were hoping for an activity or an equipment to come out of their website usage.  Look in [reviewComponent/DeliversEquipmentForm](../src/reviewComponent/DeliversEquipmentForm.jsx) and [reviewComponent/FeaturesActivityForm](../src/reviewComponent/FeaturesActivityForm.jsx) to see the review forms at they stand.



## More advanced projects

* We're interested in integrating reviews based on other sources of engagement info--reviews from foursquare checkins, calendar entries, location history, purchases, android app usage, etc.  You can check out the kind of data that's returned by [usageTracker/libusage](../src/usageTracker/libusage.js) and the way that the review is displayed in [chromeExtension/background.js](../src/chromeExtension/background.jsx) to see if you could make another source for gathering engagement data and displaying reviews.

* Usage and notification tracking on other platforms besides chrome is an open issue (e.g., app usage and notification tracing on ios and android).  See the same two files above.

* We'll want to move the backend off of Firebase sooner rather than later.  See [collectiveExperience/firebaseAdaptor](../src/collectiveExperience/firebaseAdaptor.js)

* As we collect real data, there will be a growing need for summary statistics, graphs, and admin pages to maintain it all and get an overview.
