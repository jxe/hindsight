window.F = undefined
window.owning_view = null

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
  

# add methods for path lookup and user-based lists to firebase

Firebase::[k] = v for own k, v of {
  fb: ->
    args = Array::slice.call(arguments)
    this.child args.shift().replace(/%/g, ((m) -> args.shift()))
  add_user: ->
    this.child(current_user_id).set
      name: window.current_user.name,
      image: window.current_user.image,
      at: Firebase.ServerValue.TIMESTAMP
  remove_user: ->
    this.child(current_user_id).remove()
  touch: ->
    this.setPriority(Date.now())
  delegate: (ev, fname, preprocess) ->
    del = window.owning_view
    preprocess ||= (snap) -> [snap.val()]
    cb = (snap) -> del[fname].apply(del, preprocess)
    this.on ev, cb
    del.offs.push => this.off(ev, cb)
}


window.fb = ->
  F.fb.apply(F, Array::slice.call(arguments))
