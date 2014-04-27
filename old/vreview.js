function with_page_info(url, cb){
	$.ajax({
		url: "/url/" + encodeURIComponent(url),
		dataType: 'json',
		success: function(data) {
			cb(url, data.title, data.title);
		}
	});
}

function canonicalize_link(url){
	if (!url) return;
	if (url.match(/^http/)){
		// strip http(s?)
		var match = url.match(/:\/\/(.[^/]+)/);
		if (!match) return url;
		// and leading www.
		return (match[1]).replace('www.','');
	} else {
		return url;
	}
}

function encodeFirebasePath(path){
	return encodeURIComponent(path).replace(/\./g, '%2E');
}

function id_for_link(url){
	return encodeFirebasePath(canonicalize_link(url));
}

function guess_type_of_link(data){
	if (!data) return '';
	var link = data.url || data.name || data;
	if (link.match(/vimeo|youtube/)) return 'a video';
	else if (link.match(/itunes|play/)) return 'an app';
	else if (link.match(/amazon|stripe|square|etsy|groupon/)) return 'a product';
	else if (link.match(/yelp|foursquare/)) return 'a venue';
	else return 'a website';
}


// jumpers

function jump_to_link(link){
	var raw_link = decodeURIComponent(link);
	link_detail(encodeFirebasePath(link), raw_link);
}



// jump from URL

if (m = window.location.hash.match(/user\/(.*)$/)){
	console.log('matched!', m[1]);
	// on_auth = function(){ jump_to_user(m[1]); }
	jump_to_user(m[1]);
} else if (m = window.location.hash.match(/url\/(.*)$/)){
	console.log('matched!');
	// on_auth = function(){ jump_to_link(m[1]); }
	jump_to_link(m[1]);
}
