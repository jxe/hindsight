
## quick extensions to the spacepen ##

View::[k] = v for own k, v of {
  sub: (ref, ev, fn) ->
    ref.on(ev, fn)
    (@offs ||= []).push -> ref.off(ev, fn)
  beforeRemove: ->
    o() for o in @offs if @offs
}


class window.Modal extends View
  @show: (args...) ->
    x = new this(args...)
    x.appendTo 'body'
    setTimeout((-> x.toggleClass 'active'), 0)
  close: ->
    this.toggleClass('active')
    setTimeout((=> this.remove()), 1000)



window.gerunds =
  buy: 'buying'
  visit: 'visiting'
  watch: 'watching'
  listen: 'listening'
  read: 'reading'

window.pasttense =
  buy: 'bought'
  visit: 'visited'
  watch: 'watched'
  listen: 'listened'
  read: 'read'


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
        F.child("users").child(user.uid).update
          name: user.displayName
          facebook_id: facebook_id
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

window.fb = ->
  F.fb.apply(F, Array::slice.call(arguments))
