batshit.setup_firebase();
batshit.authenticate();

window.loadPopup = function (el){
  chrome.tabs.query({active:true, currentWindow:true}, function(tabs){
    var url = tabs[0].url;
    Review.for_url(url, function(r){
      $(el).html(r);
    });
  });
};

chrome.runtime.onMessageExternal.addListener(
  function(request, sender, sendResponse) {
    if (request.acceptFirebaseToken){
      F.auth(request.acceptFirebaseToken);
      batshit.setup_user(request.user);
      console.log('Firebase token accepted');
    }
  }
);
