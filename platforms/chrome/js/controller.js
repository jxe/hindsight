// controller.js

function fnGetDomain(url){
    if (!url) return;
    var match = url.match(/:\/\/(.[^/]+)/);
    if (!match) return url;
    return (match[1]).replace('www.','');
}


NoRegrets = { currentURL: "", start_time: 0, timer: null };


chrome.browserAction.onClicked.addListener(function(){
	chrome.tabs.query({active:true, currentWindow:true}, function(tabs){
		var tab = tabs[0];
		var url = tab.url;
		Controller.show_review_prompt(tab.id, tab.url);
	})
});


Controller = {
	on_page_up_for_a_bit: function (url, tab) {
		// console.log('on_page_up_for_a_bit');
		var summary_data = Page.is_ripe_for_review(url);
		if (summary_data){
			this.show_review_prompt(tab, url, summary_data);
		}
	},

	show_review_prompt: function(tab, url, summary_data){
		if (!summary_data) summary_data = NRHistory.query(url);
		console.log("show_review_prompt")
		NoRegrets.url_data = summary_data;
        console.log("summary_data", summary_data);
		if (!summary_data.common_ratings){
			Page.common_ratings(summary_data.url, function(answer){
				summary_data.common_ratings = answer;
			});
		}
        chrome.tabs.executeScript(tab, {file: "inject/show_review_bar.js"});
	},

    on_user_focused_on_url: function(url, tab) {
    	if (!url) url = NoRegrets.currentURL;
        url = fnGetDomain(url);
        if (!url) return;
    	console.log('user focused on: ' + url);
        if (NoRegrets.currentURL && NoRegrets.currentURL != url) Controller.on_user_blurred_on_url();
        NoRegrets.currentURL = url;
        if (tab) NoRegrets.currentTitle = tab.title;
        NoRegrets.start_time = new Date();
        if (!tab) return;
        // console.log('setting timer');
        if (NoRegrets.timer) clearTimeout(NoRegrets.timer);
        NoRegrets.timer = setTimeout(function(){
	        // console.log('timer running');
        	if (NoRegrets.currentURL == url){
        		Controller.on_page_up_for_a_bit(url, tab.id);
        	}
        }, 5*1000);
    }, 

    on_user_blurred_on_url: function(url, tab, title) {
        url = url || NoRegrets.currentURL;
        title = title || NoRegrets.currentTitle;
        url = fnGetDomain(url);
        if (!url) return;
        // console.log('url: ' + url);
        var blame_url = null;
        var t1 = (new Date()).getTime();
        if (!NoRegrets.start_time) return;
        var dt = t1 - NoRegrets.start_time.getTime();
        // console.log("dt: " + dt);
        NRHistory.add(t1, dt, url, title, blame_url);
    }
};


chrome.tabs.onUpdated.addListener(function(tabId,changeInfo,tab){
	console.log('tab loaded');
    if(tab.url.indexOf("http://") != -1 || tab.url.indexOf("https://") != -1){
        if(changeInfo.status == 'complete'){
            Controller.on_user_focused_on_url(tab.url, tab);
        }
    }
});

chrome.tabs.onCreated.addListener(function(tab){
    if((tab.url.indexOf("http://") != -1 || tab.url.indexOf("https://") != -1)){
        Controller.on_user_focused_on_url(tab.url, tab);
    }
});

chrome.tabs.onRemoved.addListener(function(tabId,removeInfo){
    console.log("tab removed");
    Controller.on_user_blurred_on_url();
});


chrome.idle.onStateChanged.addListener(function(new_state){
	if (new_state != 'active'){
		Controller.on_user_blurred_on_url();
	} else {
		Controller.on_user_focused_on_url();
	}
});



chrome.runtime.onMessage.addListener(
  function(request, sender, sendResponse) {

    if (request.just_close){
        console.log('got close request');
        sendResponse({on_it:true});
        chrome.tabs.sendMessage(sender.tab.id, {close_iframe: true});
    }

    if (request.just_hide){
        sendResponse({on_it:true});
        chrome.tabs.sendMessage(sender.tab.id, {hide_iframe: true});
    }

  	if (request.rating){
	  	sendResponse({on_it:true});
	  	Page.add_rating(request);
        if (request.followup_action != 'stay_open'){
            chrome.tabs.sendMessage(sender.tab.id, {close_iframe: true});
        }
  	}

  	if (request.gimme_url_data){
        console.log('got request!');
  		var summary_data = NoRegrets.url_data;
        if (!summary_data){
            console.log('Impossible!');
            return false;
        }
		if (!summary_data.common_ratings){
            console.log('branch A!');
			Page.common_ratings(summary_data.url, function(answer){
		  		// console.log("sending url data after fb: " + JSON.stringify(summary_data));
				summary_data.common_ratings = answer;
				sendResponse({url_data:summary_data});
			});
			return true;
		} else {
            console.log('branch B!');
	  		// console.log("sending url data: " + JSON.stringify(summary_data));
		  	sendResponse({url_data:summary_data});			
		}
        console.log('response sent!');
  	}

    if(request.akce == 'content'){
        if (request.focus == 'focus') {
		    // console.log("content focused");
            Controller.on_user_focused_on_url(request.url, sender.tab);
        } else if (request.focus == 'blur') {
		    // console.log("content blurred");
            Controller.on_user_blurred_on_url(request.url, sender.tab, sender.tab.title);
        }
    }

    if(request.open_shelf){
        chrome.tabs.sendMessage(sender.tab.id, request);
    }

    if(request.open_shelf_to){
        chrome.tabs.sendMessage(sender.tab.id, request);
    }

  }
);

