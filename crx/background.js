batshit.setup_firebase();
batshit.authenticate();

function withCachedPlusUserID(cb){
  if (localStorage.plusUser) return cb(localStorage.plusUser);
  chrome.identity.getAuthToken({interactive: true}, function(authToken){
    $.ajax({
      url: 'https://www.googleapis.com/plus/v1/people/me',
      headers: {
          'Authorization': 'Bearer ' + authToken
      },
      success: function (response) {
          console.log("Received user id: ", response.id);
          localStorage.plusUser = "plus:" + response.id;
          cb(localStorage.plusUser);
      },
      error: function (error) { console.error(error); }
    });
  });
}

window.loadPopup = function (el){
  withCachedPlusUserID(function(userid){
    console.log('using userid', userid);
    chrome.tabs.query({active:true, currentWindow:true}, function(tabs){
      Resource.fromChromeTab(tabs[0]).reviewByUser(userid).inject(el);
    });
  })
};

chrome.runtime.onMessageExternal.addListener(
  function(req) {
    if (req.user) batshit.setup_user(req.user);
  }
);
