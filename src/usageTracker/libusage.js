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
      var tab = tabs[0]
      var url = BrowserEvents.cleanURL(tab.url)
      var engagement = this.getEngagement(url)
      cb({
        url: url,
        name: url,
        favIconUrl: tab.favIconUrl,
        usage: engagement.usage,
        indirectUsage: engagement.indirectUsage
      })
    })
  },

  getEngagement(url){
    var directBouts = UsageRecord.allBouts(url, 'direct')
    var indirectBouts = UsageRecord.allBouts(url, 'indirect')
    var t0 = Date.now() / 1000
    if (directBouts && directBouts[0] && directBouts[0][0]){
      t0 = directBouts[0][0]
    }
    var win = [t0, Date.now() / 1000]
    return {
      usage: { window: win, bouts: directBouts || [], },
      indirectUsage: { window: win, bouts: indirectBouts || [] }
    }
  }

}
