function sendFocus(focus){
    chrome.extension.sendMessage({
    	akce:'content', 
    	focus:focus,
    	url: location.href
    },function(response){});
}

window.addEventListener('focus',function(){
    sendFocus('focus');
},false);

window.addEventListener('blur',function(){
    sendFocus('blur');
},false);
