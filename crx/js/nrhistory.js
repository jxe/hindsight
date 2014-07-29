// uses localStorage to store history efficiently
// public api, just add() and query()
// localstorage schema explained at end

NRHistory = {
	
	// t = starttime
	// dt = timespent on site
	// url = site
	// blame_url = addl url to blame for visit (e.g. fb or twitter)
	add: function(t, dt, url, title, blame_url){
		console.log('adding ' + dt + " to " + url);
		this.incr_bout(url, 'dt', t, dt, url, title);
		if (blame_url) this.incr_bout(blame_url, 'it', t, dt, url, title);
	},

	// dt = direct time, it = indirect time, titles = some page titles
	query: function(url){
		var root_domain = this.root_domain(url);
		var sum = { url: root_domain, dt: 0, it: 0, titles: [] };
		var weeks = [this.weeks_ago(0), this.weeks_ago(1), this.weeks_ago(2)];
		this.each_bout_in_weeks(root_domain, weeks, function(bout){
			NRHistory.add_bout_to_sum(sum, bout);
		});
		return sum;
	},



	// private

	start_of_day: function(t){
		var start = t ? new Date(t) : new Date();
		start.setHours(0,0,0,0);
		return start.getTime();
	},

	start_of_week: function(t){
		var start = t ? new Date(t) : new Date();
		var first = start.getDate() - start.getDay();
		start.setDate(first);
		start.setHours(0,0,0,0);
		return start.getTime();
	},

	incr_bout: function(to_url, type, t, dt, url, title){
		var root_domain = this.root_domain(to_url);
		var bout = this.find_or_create(root_domain, t);
		bout[type] = bout[type] + dt;
		if (!bout.visits[url]) bout.visits[url] = {title:title, t:0};
		bout.visits[url].t = bout.visits[url].t + dt;
		localStorage[bout.id] = JSON.stringify(bout);
	},

	find_or_create: function(root_domain, t){
		return this.find(root_domain, t) || this.create(root_domain, t);
	},

	find: function(root_domain, t){
		var sod = this.start_of_day(t);
		var bouts_on_day = localStorage[root_domain + "/day:" + sod];
		if (bouts_on_day){
			var first = bouts_on_day.split(', ')[0];
			if (localStorage[first]) return JSON.parse(localStorage[first]);
		}
	},

	create: function(root_domain, t){
		var id = root_domain + "/bout:" + t;
		var bout = { id: id, dt: 0, it: 0, visits: {} };
		var sod = this.start_of_day(t);
		var sow = this.start_of_week(t);
		this.add_to_set(root_domain + "/weeks", sow);
		this.add_to_set(root_domain + "/week:" + sow + "/days", sod);
		this.add_to_set(root_domain + "/day:" + sod, id);
		return bout;
	},

	add_to_set: function(loc, str){
		var current = localStorage[loc];
		if (!current) return localStorage[loc] = str;
		if (current.split(', ').indexOf(str) != -1) return;
		localStorage[loc] = localStorage[loc] + ", " + str;
	},

	weeks_ago: function(n){
		return this.start_of_week() - n * 24*60*60*7;
	},

	add_bout_to_sum: function(sum, bout){
		sum.dt += bout.dt;
		sum.it += bout.it;
		sum.titles = sum.titles.concat(this.titles_for_bout(bout));
	},

	each_bout_in_weeks: function(root_domain, weeks, fn){
		weeks.forEach(function(week){
			// console.log('checking week: ' + week);
			var days = localStorage[root_domain + "/week:" + week + "/days"];
			if (days){
				days.split(', ').forEach(function(day){
					// console.log('checking day: ' + day);
					var bouts = localStorage[root_domain + "/day:" + day];
					bouts.split(', ').forEach(function(bout_id){
						fn(JSON.parse(localStorage[bout_id]));
					});
				});
			}
		});
	},

	titles_for_bout: function(bout){
		var titles = [];
		for (var url in bout.visits){
			if (bout.visits[url].title) titles.push(bout.visits[url].title);
		}
		return titles;
	}, 

	root_domain: function(url){
	    var match = url.match(/:\/\/(.[^/]+)/);
	    if (!match) return url;
	    return (match[1]).replace('www.','');
	}

};

// localstorage["<URL>"] = "[weekno, ...]"
// localstorage["<URL>/week:<weekno>"] = "[start_of_day, ...]"
// localstorage["<URL>/day:<start_of_day>"] = "[bout_start, ...]"
// localstorage["<URL>/bout:<bout_start>"] = {
//		id: "<URL>/bout:<bout_start>",
// 		dt: 202031, 
// 		it: 202031,
// 		visits: {
// 			url: {title:"", t:0123} }
// 		}
// }
