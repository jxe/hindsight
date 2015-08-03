// LibUsage

// TODO: support blame_url / indirect usage
// TODO: topSites: function(){},


import UsageRecord from './usageRecord.js'
import BrowserEvents from './browserEvents.js'


export default {

  instrumentChrome(){
    BrowserEvents.instrumentChrome(UsageRecord)
  },

  withEngagementForCurrentURL(cb){
    chrome.tabs.query({active:true, currentWindow:true}, tabs => {
      cb(this.getEngagement(tabs[0].url))
    })
  },

  getEngagement(url){
    url = BrowserEvents.cleanURL(url)
    var directBouts = UsageRecord.allBouts(url, 'direct')
    var indirectBouts = UsageRecord.allBouts(url, 'indirect')
    var window = [directBouts[0][0], Date.now() / 1000]
    return {
      url: url,
      name: url,
      length: "a million years",
      usage: { window: window, bouts: directBouts, },
      indirectUsage: { window: window, bouts: indirectBouts }
    }
  }

}
