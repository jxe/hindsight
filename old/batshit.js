var batshit = {};


// in-page routing

batshit.meta  = function (attr){
    var metas = document.getElementsByTagName('meta');
    for (var x=0,y=metas.length; x<y; x++) {
        if (metas[x].name == attr) return metas[x].content;
    }
};

batshit.parse_my_url = function(){
    var route = batshit.meta('route');
    var assignments = [];
    var regex = route.replace(/:(\w+)/, function(m) {
        console.log(m.slice(1));
        assignments.push(m.slice(1));
        return "(.*?)";
    });
    regex += "$";
    var base = window.location.pathname + window.location.search;
    var m = base.match(regex);
    if (!m) return alert('unrecognized path for: ' + route);
    console.log(m);
    for (var x=0; x<assignments.length; x++) window[assignments[x]] = m[x+1];
};



// building blocks

batshit.$ = function(x, fn){
    if (x.on || x.addEventListener) return fn ?  fn(x) : x;
    if (!fn) return (batshit.focus || document).querySelector(x);
    var els = (batshit.focus || document).querySelectorAll(x);
    for (var i = 0; i < els.length; i++) fn(els[i]);
};

batshit.on = function(el, ev, c){
    batshit.$(el, function(el){
        if (!el.on){ el.on = el.addEventListener; el.off = el.removeEventListener; }
        if (!el.listeners) {
            el.listeners = {};
            el.addEventListener('unwire', function(ev){
                for (var k in el.listeners) el.off(k, el.listeners[k]);
                el.listeners = {};
            });
        }
        if (el.listeners[ev]) el.off(ev,el.listeners[ev]);
        el.listeners[ev] = c;
        el.on(ev, c);
    });
};




// define some widgets

(function () {
    var $ = batshit.$, on = batshit.on;

    batshit.input = function(id, onchange){
        var el = $(id);
        on(el.form, 'submit', function(ev){ onchange(el.value); ev.preventDefault(); el.value = ''; return false; });
    };

    batshit.button = function(id, does){
        on(id, 'click', function (ev) { ev.preventDefault(); does(); return false; });
    };

    batshit.dataupload = function (id, cb) {
        on(id, 'change', function (ev) {
            var f = ev.target.files[0];
            var reader = new FileReader();
            reader.onload = function(e) { cb(e.target.result); };
            reader.readAsDataURL(f);
        });
    };

    batshit.object = function (el, o, calcfns) {
        if (calcfns) for (var k in calcfns) o[k] = calcfns[k](o);
        mikrotemplate($(el), o);
    };

    batshit.tabs = function (el, tabnames, onchange, default_tab) {
        el = $(el);
        var array = tabnames.map(function (n) { return {name: n}; });
        mikrotemplate(el, array);
        var children = el.childNodes;
        var f = function(ev, tab_el){
            if (!tab_el) tab_el = this;
            var prev_selected = el.querySelectorAll('.selected');
            Array.prototype.forEach.call(prev_selected, function(x){ x.setAttribute('class', ''); });
            tab_el.setAttribute('class', 'selected');
            onchange( tab_el.data.name, ev );
        };
        for (var i = children.length - 1; i >= 0; i--){
            children[i].onclick = f;
            if (children[i].data.name == default_tab) f(null, children[i]);
        }
    };

    batshit.hidable = function(el, shown){
        el = $(el);
        el.show = function(shown){
            if (!shown){
                el.classList.add('hiding');
                el.classList.add('hidden');
                el.style.display = 'none';
                el.classList.remove('hiding');
            } else {
                el.classList.add('revealing');
                el.style.display = '';
                el.classList.remove('revealing');
                el.classList.add('revealed');
            }
        };
        el.show(shown);
    };

    batshit.toggle = function(el, does, start_state){
        el = $(el);
        var state = start_state;
        el.state = function(s, ev){
            state = s;
            if (state) el.classList.add('on');
            else el.classList.remove('on');
            does(state, el, ev);
        };
        on(el, 'click', function (ev) {
            ev.preventDefault();
            el.state(!state, ev);
            return false;
        });
    };

    batshit.list = function(el, array, onclick){
        el = $(el);
        el.render = function(array){
            mikrotemplate(el, array);
            if (!onclick) return;
            var children = el.childNodes;
            var f = function(ev){ onclick( this.data, ev, this ); };
            for (var i = children.length - 1; i >= 0; i--) children[i].onclick = f;
        };
        if (array) el.render(array);
    };

})();




// mikrotemplate

function mikrotemplate(el, obj_or_array, id_pfx){
    function decorate_element(el, json){
        var directive_string = el.getAttribute('data-set');
        var directives = directive_string ? directive_string.split(' ') : [];
        directives.forEach(function(word){
            var parts = word.split(':');
            var attr = parts[1] ? parts[0] : 'text';
            var path = parts[1] || parts[0];
            if (attr == 'text')       el.innerHTML = json[path];
            else if (attr == 'value') el.value = json[path];
            else el.setAttribute(attr, json[path]);
        });
    }
    function decorate_subtree(el, json){
        el.data = json;
        decorate_element(el, json);
        var matches = el.querySelectorAll('[data-set]');
        for (var i = 0; i < matches.length; i++) decorate_element(matches[i], json);
    }
    if (!id_pfx) id_pfx = '';
    if (!obj_or_array) return;
    if (!obj_or_array.forEach) return decorate_subtree(el, obj_or_array);
    if (!el.mikrotemplate) el.mikrotemplate = el.firstElementChild.cloneNode(true);
    el.innerHTML = "";
    obj_or_array.forEach(function(o){
        var clone = el.mikrotemplate.cloneNode(true);
        clone.id = id_pfx + o.id;
        decorate_subtree(clone, o);
        el.appendChild(clone);
    });
}











// firebase stuff (flaming bat shit)

var F, facebook_id, facebook_name, current_user_id, on_auth, firebase_auth;

batshit.setup_firebase = function () {
    if (!F) F = new Firebase(batshit.meta('firebase'));
};

batshit.authenticate = function (cb) {
    batshit.setup_firebase();
    window.on_auth_ready = cb;
    firebase_auth = new FirebaseSimpleLogin(F, function(error, user) {
        if (error) return alert(error);
        if (user) {
            current_user_id = user.uid;
            facebook_id = user.id;
            facebook_name = user.displayName;
            F.child('users').child(user.uid).update({
                name: user.displayName,
                facebook_id: facebook_id
            });
        }
        if (window.on_auth_ready) window.on_auth_ready();
        window.auth_ready = true;
    });
};

batshit.please_login = function  () {
    alert('Please login with facebook to complete this action!');
    firebase_auth.login('facebook', { rememberMe: true });
};

function fb(){
    var args = Array.prototype.slice.call(arguments);
    var str = args.shift();
    var path = str.replace(/%/g, function(m){ return args.shift(); });
    return F.child(path);
}






Firebase.prototype.paint = function(el, calcfns){
    var ref = this;
    el = batshit.$(el);
    batshit.on(ref, 'value', function(snap){
        var o = snap.val() || {};
        if (calcfns) for (var k in calcfns) o[k] = calcfns[k](o);
        mikrotemplate(el, o);
    });
};


Firebase.prototype.paint_list = function(el, onclick, calcfns){
    function values(obj){
        if (!obj) return [];
        return Object.keys(obj).map(function(x){ obj[x].id = x; return obj[x]; });
    }

    var ref = this;
    el = batshit.$(el);
    batshit.on(ref, 'value', function(snap){
        var value = snap.val();
        var array = value ? values(value) : [];
        if (calcfns) array.forEach(function(o){
            for (var k in calcfns){
                o[k] = calcfns[k](o, function(v){
                    var item = document.getElementById(o.id);
                    o[k] = v;
                    mikrotemplate(item, o);
                });
            }
        });
        mikrotemplate(el, array);
        if (onclick) {
            var children = el.childNodes;
            for (var i = children.length - 1; i >= 0; i--) {
                children[i].onclick = function(ev){ onclick( this.data, ev, this ); };
            }
        }
    });
};
