
## quick extensions to the spacepen ##

View::[k] = v for own k, v of {
  sub: (ref, ev, fn) ->
    ref.on(ev, fn)
    (@offs ||= []).push -> ref.off(ev, fn)
  beforeRemove: ->
    o() for o in @offs if @offs
}


F = undefined
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
    F = new Firebase(batshit.meta("firebase"))  unless F
  authenticate: (cb) ->
    batshit.setup_firebase()
    window.on_auth_ready = cb
    firebase_auth = new FirebaseSimpleLogin F, (error, user) ->
      return alert(error)  if error
      if user
        window.current_user_id = user.uid
        window.facebook_id = user.id
        window.facebook_name = user.displayName
        F.child("people").child(user.uid).update
          name: user.displayName
          facebook_id: facebook_id
          photo: 'https://graph.facebook.com/' + facebook_id + '/picture'
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
    name: window.facebook_name,
    image: "https://graph.facebook.com/#{facebook_id}/picture",
    at: Firebase.ServerValue.TIMESTAMP

Firebase.prototype.remove_user = ->
  this.child(current_user_id).remove()

Firebase.prototype.touch = ->
  this.setPriority(Date.now())

Firebase.prototype.set_mirror_loc = (obj, value) ->
  r = this.root().toString()
  path = this.toString().split(r)[1]
  dirs = path.split('/')
  dirs.shift()
  console.log(dirs)
  last = dirs.pop()
  obj[r] = {} if !obj[r]
  obj = obj[r]
  for x in dirs
    obj[x] = {} if !obj[x]
    obj = obj[x]
  obj[last] = value

Firebase.prototype.plus = (ref, cb) ->
  q = new FirebaseQuery()
  q.plus this
  q.plus ref, cb
  q

window.fb = ->
  F.fb.apply(F, Array::slice.call(arguments))

class window.FirebaseQuery
  constructor: ->
    @v = {}
    @q = {}
    @on = null
  on_full_value: (cb) ->
    @on = cb
  check: ->
    for k, v of @q
      if !v
        return false
    @on(@v) if @on
  plus: (ref, cb) ->
    @q[ref.toString()] = false
    ref.on 'value', (snap) =>
      v = snap.val()
      ref.set_mirror_loc(@v, v)
      @q[ref.toString()] = true
      cb(v, this) if cb
      @check()
    this
