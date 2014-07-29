// nrpage.js

var F = new Firebase('https://no-regrets.firebaseio.com');

Page = {
	escape_url: function(url){
		return url.replace(/\./g, '•').replace(/\//g, '»');
	},

	rollup_rating: function(rating){
		if (rating.match(/^tws:/)) return "tws:*";
		else return "suboptimal:*";
	},

	is_ripe_for_review: function(url) {
		if (url.match(/localhost|127/)) return false;
		// console.log("checking is_ripe_for_review");
		if (this.has_been_reviewed(url)) return false;
		data = NRHistory.query(url);
		// console.log("got data: " + JSON.stringify(data));
		if (data) console.log("You've spent: " + data.dt + " at root url: " + url);
		if (data.dt < 30*60*1000) return false;
		return data;
	},

	has_been_reviewed: function(url) {
		return localStorage["reviewed:" + url];
	},

	add_rating: function(obj){
		F.child('ratings').push(obj);
		obj.urls.forEach(function(url){
			localStorage["reviewed:" + url] = JSON.stringify(obj);
			var eurl = Page.escape_url(url);
			[obj.rating, Page.rollup_rating(obj.rating)].forEach(function(rating){
				// TODO: a problem for facebook.com/suboptimal:*, google.com/tws:*, etc
				F.child('urls').child(eurl).child(rating).transaction(function(val){
					if (!val) val = { dt:0, it:0, ct:0, titles: [] };
					val.dt += obj.dt;
					val.it += obj.it;
					val.ct += 1;
					val.titles = val.titles.concat(obj.titles || [])
					val[".priority"] = 1 / val.dt;
					return val;
				});
			});
		});
	},

	common_ratings: function(url, callback){
		var eurl = Page.escape_url(url);
		console.log('calling out to FB');
		F.child('urls').child(eurl).limit(100).on('value', function(snap){
			console.log('got data from FB');
			var val = snap.val();
			if (val) val.top_wishes = Page.wishes(val);
			callback(val);
		});
	},

	wishes: function(data) {
	  var wishes = [];
	  var m;
	  Object.keys(data).forEach(function(k){
	    if (m = k.match(/^suboptimal:(.*)/)){
	      if (m[1] != '*') wishes.push(m[1]);
	    }
	  });
	  return wishes.length ? wishes : null;
	}

};


// FB/ratings/
//   urls: [],
//   titles: [],
//   dt
//   it
//   rated: "tws:foo"
// FB/urls/
// 	<url>
// 		tws:*
// 		tws:<category>
// 			dt
// 			it
// 			rated_ct
// 			titles: []
