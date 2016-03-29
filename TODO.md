## hindsight / reasons classes

m1 - card is no longer bullshit / contains actual usage numbers
m2 - card submits to database
m3 - eyeball updates
---
m4 - reasons browser has new types, & can add reasons
m5 - card demands reasons
---
m6 - multiple correct cards appear
m7 - reasons browser can add synonyms etc
m8 - card looks nice



TODO:  
* chromeActivities should be able to restart trails on extension reload



m1 **2h**

* hindsight shell
* minimal Composer
* minimal assessments/Card
* assessments/storage#saveAssessment()
* storage#createReason()

m2

* Composer  **2h**
* assessments/Card **1h**
* assessments/ActivityExplanationView **15m**

m3

* Composer - posts to src/storage (2h)
* src/storage - **1h**

  #suggestedReasons(url) => promise?
  #create(type, text, cb(newId))
  #find(id) => promise?
  #completions(str)

* src/EntryField - pulls from src/storage (20m)
* src/SuggestionsList - also pulls from src/storage (30m)

m4

* src/assessments/storage -

  browserHistory.js
  timelines.js
  index.js                    **2h**
    #isAssessed?(uid,url)
    #unassessedActivities(uid, url) => activity[]
    #recentAssessedActivities(uid, url) => activity[]
    #saveAssessment(uid, activity, reasons, disposition)

m5

* assessments/Card - generated from assessments/storage




**7h**


src/assessments

  PastAssessmentsList        **30m**








## Data formats:

activity = {
  url: "",
  timeframe: [],
  timeline: {},
  headline: "",
  details: "",
  urls: []
}
