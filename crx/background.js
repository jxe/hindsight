window.loadPopup = function (el){
  User.loggedIn(function(){
    chrome.tabs.query({active:true, currentWindow:true}, function(tabs){
      Resource.fromChromeTab(tabs[0]).reviewByUser(current_user_id).inject(el);
    });
  });
};
