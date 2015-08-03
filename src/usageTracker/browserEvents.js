// BrowserEvents

var currentURL, currentTitle, t0, history;

export default {
  cleanURL(url){
    if (url && !url.match(/^https?\:\/\//)) return
    if (!(url = url || currentURL)) return
    var m = url.match(/:\/\/(.[^/]+)/)
    return m ? (m[1]).replace('www.','') : url
  },

  focus: function(url, tab) {
    if (!(url = this.cleanURL(url))) return;
    if (currentURL && currentURL != url) this.blur();
    currentURL = url;
    if (tab) currentTitle = tab.title;
    t0 = Date.now()/1000
  },

  blur: function(url, tab) {
    if (!t0 || !(url = this.cleanURL(url))) return;
    var title = tab ? tab.title : currentTitle
    if (history) history.add(t0, (Date.now()/1000) - t0, url, title)
  },

  instrumentChrome: function(usageRecord){
    history = usageRecord
    chrome.tabs.onUpdated.addListener((tabId,changeInfo,tab) => {
      if (changeInfo.status == 'complete') this.focus(tab.url, tab)
    })
    chrome.tabs.onCreated.addListener((tab) => {
      this.focus(tab.url, tab);
    })
    chrome.tabs.onRemoved.addListener(
      (tabId,removeInfo) => this.blur()
    )
    chrome.idle.onStateChanged.addListener((new_state) => {
      new_state != 'active' ? this.blur() : this.focus()
    })
    chrome.runtime.onMessage.addListener((m, sender, sendResponse) => {
      if (m.akce != 'content' || !m.focus) return
      this[m.focus].call(this, m.url, sender.tab)
    })
  }
}


// if (!tab) return;
// console.log('setting timer');
// if (NoRegrets.timer) clearTimeout(NoRegrets.timer);
// NoRegrets.timer = setTimeout(function(){
//   // console.log('timer running');
//   if (NoRegrets.currentURL == url){
//     Controller.on_page_up_for_a_bit(url, tab.id);
//   }
// }, 5*1000);

// on_page_up_for_a_bit: function (url, tab) {
//   var summary_data = Page.is_ripe_for_review(url);
//   if (summary_data){
//     this.show_review_prompt(tab, url, summary_data);
//   }
// },
