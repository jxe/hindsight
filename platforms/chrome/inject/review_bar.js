var review_data;

function review_as(rating, followup_action){
    chrome.runtime.sendMessage({
      rating: rating,
      followup_action: followup_action,
      urls: [review_data.url],
      dt: review_data.dt,
      it: review_data.it,
      titles: review_data.titles,
    }, function(response) {});  
}

function resizeBasedOnTypeahead(){
  var el = $('.tt-dropdown-menu:visible'),
      height = el.length > 0 ? el.height() + el.offset().top + 30 : 200
  height = Math.max( 200, height )
  chrome.runtime.sendMessage({open_shelf_to: height, duration: 100})  
}

function showBarMessage(msg){
  $('.more').fadeIn()
  $('#bar_msg').html(msg).css({opacity:1})
  chrome.runtime.sendMessage({open_shelf_to: 35})    
}

$('#tws input').typeahead({
  local: ['creative projects', 'learning', 'porn']
}).on('typeahead:selected change', function(ev, chosen){
  var val = chosen ? chosen.value : ev.target.value
  showBarMessage('GLAD THAT WAS TIME WELL SPENT ON: ' + val )
  review_as('tws:' + val, 'stay_open');
  setTimeout(function(){
    chrome.runtime.sendMessage({just_close: true})    
  }, 4500)

}).on('keyup', resizeBasedOnTypeahead);

$('#suboptimal input').typeahead({
  local: ['with girlfriend', 'jogging', 'reading a goddamn book', 'golfing', 'sleeping']
}).one('typeahead:selected change', function(ev, chosen){
  var val = chosen ? chose.value : this.value;
  review_as('suboptimal:' + val, 'stay_open');
  $('.more').hide();
  $('#followup').show();
  $('#followup textarea').val("Anyone want to go "+val+"? #noregrets");
}).on('keyup', resizeBasedOnTypeahead);


$('#followup button').on('click', function(){
  var msg = $('#followup textarea').val();
  // launch twitter intent
  window.open("https://twitter.com/intent/tweet?text=" + encodeURIComponent(msg), '_blank', "height=420,width=550,centerscreen,scrollbars=yes,resizable=yes,toolbar=no,location=yes");
  chrome.runtime.sendMessage({ just_close: true  }, function(response) {});
});

function summarize_user_count_and_hours(subtree, what){
  return subtree.ct + " users who've spent a collective " + moment.duration(subtree.dt).humanize() + " found it " + what;
}

function cute_summary_of_ratings(data){
  var findings = [];
  if (!data) return "";
  if (data["tws:*"]) findings.push(summarize_user_count_and_hours(data["tws:*"], "time well spent"));
  if (data["suboptimal:*"]) findings.push(summarize_user_count_and_hours(data["suboptimal:*"], "suboptimal"));
  var str = findings.join(' and ') + "<br>";
  if (data.top_wishes) str += "<br>Those that found it suboptimal wish they'd been: " + data.top_wishes.join(', ');
  return str;
}

$('body').click(function(){
  if( window.regret_open ) return true;
  chrome.runtime.sendMessage({open_shelf:true})
  window.regret_open = true;

  $('#bg h1').transition({opacity: 0})
  $('.more')
    .transition({
      left: '25%'
    })
  $('#bg .more').fadeIn()
  $('#bg').css('cursor', 'default');
  jiggleGraph()
});

$('.close').click(function(){
    console.log('sending close request');
    chrome.runtime.sendMessage({ just_close: true  }, function(response) {});
});


console.log('asking for review data');
chrome.runtime.sendMessage({gimme_url_data: "please"}, function(response) {
    review_data = response.url_data;
    console.log("got review_data: ", review_data);
    $('.url').html(response.url_data.url);
    $('#total_direct_time').html(moment.duration(response.url_data.dt, 'ms').humanize());
    $('#title').html(response.url_data.titles[0]);
    $('#others_rated').each(function(){
      cute_summary_of_ratings(response.url_data.common_ratings)
      $(this).html(cute_summary_of_ratings(response.url_data.common_ratings));
    })
});



function Panels(){
  var offset = $('.panels').offset(),
      curPanel = 0

  this.show = function(panelNum){

    $('.panel.active').css({position: 'absolute'}).animate({
      left: -1000,
      opacity: 0,
      duration: 150
    }).removeClass('active')

    $('.panel').eq(panelNum).css({
      left: 1000,
      opacity: 0,
      position: 'absolute'
    }).delay(50).animate({
      left: 0,
      opacity: 1,
      duration: 150
    }).addClass('active')
      .find('input').focus()

    curPanel = panelNum
  }
}

var panels = new Panels()

$('#b_tws').click(function(){
  panels.show(1)
  $('.return_hint').addClass("pulse")
  chrome.runtime.sendMessage({open_shelf_to: 200})
  $('.stats').animate({left: -1000, duration: 150, opacity: 0})
})


$('#b_rb').click(function(){
  panels.show(2)
  $('.return_hint').addClass("pulse")
  chrome.runtime.sendMessage({open_shelf_to: 200})
  $('.stats').animate({left: -1000, duration: 150, opacity: 0})
})

$('.remind').click(function(){
  var height = 550
  chrome.runtime.sendMessage({open_shelf_to: height, duration: 350}) 
  $('.stats').fadeIn()
  $('.remind').hide()
  setTimeout( jiggleGraph, 300 )

})

// For debugging: fake a click if the page is loaded directly
if(top == self){
  setTimeout(function(){
    $('body').click()
  }, 100) 
}
