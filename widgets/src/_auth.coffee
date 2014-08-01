
## quick extensions to the spacepen ##

View::[k] = v for own k, v of {
  sub: (ref, ev, fn) ->
    ref.on(ev, fn)
    (@offs ||= []).push -> ref.off(ev, fn)
  beforeRemove: ->
    o() for o in @offs if @offs
}


window.F = undefined
on_auth = undefined
firebase_auth = undefined


window.batshit =
  meta: (attr) ->
    for tag in document.getElementsByTagName("meta")
      return tag.content if tag.name is attr
  parse_my_url: ->
    route = batshit.meta("route")
    assignments = []
    regex = route.replace /:(\w+)/, (m) ->
      assignments.push m.slice(1)
      "(.*?)"
    regex += "$"
    base = window.location.pathname + window.location.search
    m = base.match(regex)
    return alert("unrecognized path for: " + route) unless m
    for assignment, i in assignments
      window[assignment] = m[i + 1]

  setup_firebase: ->
    window.F = new Firebase(batshit.meta("firebase")) unless F
  
  with_user: (el, cb) ->
    return cb() if window.current_user_id
    if x = localStorage.user
      batshit.setup_user(JSON.parse(x))
      return cb()
    # if on_auth_ready hasn't been called yet, defer this whole thing til then
    # if we have a user at that point, just call the callback
    # otherwise, set el to be an iframe pointing to auth.html
    # and when we finally get a call to setup_user, call the callback
    
  setup_user: (user) ->
    if user
      F.auth(user.firebaseAuthToken)
      window.current_user_id = user.uid
      window.facebook_id = user.id
      window.facebook_name = user.displayName
      localStorage.user = JSON.stringify(user)
      F.child("users").child(user.uid).update
        name: user.displayName
        facebook_id: facebook_id
      window.got_user(user) if window.got_user
  
  authenticate: (cb) ->
    batshit.setup_firebase()
    window.on_auth_ready = cb
    firebase_auth = new FirebaseSimpleLogin F, (error, user) ->
      return alert(error)  if error
      console.log 'running auth'
      batshit.setup_user(user)
      window.on_auth_ready() if window.on_auth_ready
      window.auth_ready = true
  
  please_login: ->
    alert "Please login with facebook to complete this action!"
    firebase_auth.login "facebook",
      rememberMe: true


Firebase.prototype.fb = ->
  args = Array::slice.call(arguments)
  this.child args.shift().replace(/%/g, ((m) -> args.shift()))

Firebase.prototype.add_user = ->
  this.child(current_user_id).set
#    name: window.facebook_name,
#    image: "https://graph.facebook.com/#{facebook_id}/picture",
    at: Firebase.ServerValue.TIMESTAMP

Firebase.prototype.remove_user = ->
  this.child(current_user_id).remove()

Firebase.prototype.touch = ->
  this.setPriority(Date.now())

window.fb = ->
  F.fb.apply(F, Array::slice.call(arguments))
