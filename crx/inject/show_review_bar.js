if (!window.has_added_no_regrets_iframe){
  window.has_added_no_regrets_iframe = true;  

  var initial_height = 35;
  var expanded_height = 200;
  var iframe = document.createElement('iframe');
  iframe.src = chrome.extension.getURL('inject/review_bar.html?param=foo#fragment');
  iframe.style.height = 0;
  iframe.style.width = '100%';
  iframe.style.position = 'fixed';
  iframe.style.top = '0';
  iframe.style.left = '0';
  iframe.style.border = "none";
  iframe.style.zIndex = '938089'; // Some high value
  iframe.style['box-shadow'] = '0 1px 0 rgba(255,255,255,.4)'
  document.documentElement.appendChild(iframe);

  var bodyStyle = document.body.style;
  var cssTransform = 'transform' in bodyStyle ? 'transform' : 'webkitTransform';
  var cssTransition = 'transition' in bodyStyle ? 'transition' : 'webkitTransition';
  bodyStyle[cssTransform] = 'translateY(0px)';

  function setAnimationStyle( animationString ){
    bodyStyle[cssTransition] = iframe.style[cssTransition] = animationString
  }

  setAnimationStyle('all .4s ease-out')

  function animateTo(height, duration){
    setAnimationStyle('all '+duration+'ms ease-in')
    iframe.style.height = height + 'px';
    bodyStyle[cssTransform] = 'translateY(' + height + 'px)';
  }

  function bounceTo(height, totalDuration){
    var distance = Math.abs(parseInt(iframe.style.height) - height),
        overshoot = height + distance*.05
        undershoot = height - distance*.03

    animateTo( overshoot, totalDuration*.6 )
    setTimeout(function(){ animateTo(height, totalDuration*.2) }, totalDuration*.8)
  }
  
  // Initial open animation
  setTimeout(function(){ bounceTo(initial_height, 350)}, 20)

  chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
    if (request.close_iframe){
      console.log("closing iframe");
      bounceTo(0, 350)
      setTimeout(function(){
        iframe.parentNode.removeChild(iframe);  
        bodyStyle[cssTransform] = "translateY(0)";
        sendResponse({done: true});
      }, 350 )
    }

    if (request.hide_iframe){
      bounceTo( initial_height, 350 )
    }

    if (request.open_shelf) {
      bounceTo( expanded_height, 350 )
    }

    if( request.open_shelf_to ) {
      console.log( 'here', request.open_shelf_to)
      bounceTo( request.open_shelf_to , request.duration || 350 )
    }

  });

}
