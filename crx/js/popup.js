chrome.extension.getBackgroundPage().loadPopup(document.body);



//chrome.tabs.query({active:true, currentWindow:true}, function(tabs){
//    var tab = tabs[0];
//    var url = tab.url;
//    var domain = fnGetDomain(url);
//
//	document.getElementById('foo').onclick = function() {
//        Controller.show_review_prompt(tab.id, tab.url);
//        window.close();
//    };
//
//	var summary = NRHistory.query(url);
//
//	var your_review = Page.has_been_reviewed(domain);
//	if (your_review) your_review = JSON.parse(your_review);
//
//	document.getElementById('domain').innerHTML = domain;
//
//	if (your_review && your_review.rating){
//		var parts = your_review.rating.split(':');
//		if (parts[0] == 'tws'){
//			document.getElementById('you_summary').innerHTML = "You said it was Time Well Spent!";
//		} else {			
//			document.getElementById('you_summary').innerHTML = "You said you wish you'd: <b>" + parts[1] + "</b>";
//		}
//	} else {
//		document.getElementById('you_summary').innerHTML = "You haven't reviewed this yet.";
//	}
//
//	console.log(domain);
//	Page.common_ratings(domain, function(answer){
//		console.log(answer);
//		if (answer){
//			document.getElementById('community_summary').innerHTML = total_time_string(answer);
//		} else {
//			document.getElementById('community_summary').innerHTML = "No Regret users are new to this site.";
//		}
//		
//	});
//});
