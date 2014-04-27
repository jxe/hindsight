
## quick extensions to the spacepen ##

View::[k] = v for own k, v of {
  sub: (ref, ev, fn) ->
    ref.on(ev, fn)
    (@offs ||= []).push -> ref.off(ev, fn)
  beforeRemove: ->
    o() for o in @offs if @offs
}




with_page_info = (url, cb) ->
  $.ajax
    url: "/url/" + encodeURIComponent(url),
    dataType: 'json',
    success: (data) ->
      cb(url, data.title, data.title);

canonicalize_link = (url) ->
  return unless url
  return url unless url.match(/^http/)
  match = url.match(/:\/\/(.[^/]+)/)
  return url unless match
  return (match[1]).replace('www.','')


encodeFirebasePath = (path) ->
  return encodeURIComponent(path).replace(/\./g, '%2E')

id_for_link = (url) ->
  return encodeFirebasePath(canonicalize_link(url))

guess_type_of_link = (data)->
  return '' unless data
  link = data.url || data.name || data;
  if link.match(/vimeo|youtube/)
    return 'a video'
  else if link.match(/itunes|play/)
    return 'an app'
  else if link.match(/amazon|stripe|square|etsy|groupon/)
    return 'a product'
  else if link.match(/yelp|foursquare/)
    return 'a venue'
  else
    return 'a website'



F = undefined
facebook_id = undefined
facebook_name = undefined
current_user_id = undefined
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
    x = 0
    while x < assignments.length
      window[assignments[x]] = m[x + 1]
      x++
  setup_firebase: ->
    F = new Firebase(batshit.meta("firebase"))  unless F
  authenticate: (cb) ->
    batshit.setup_firebase()
    window.on_auth_ready = cb
    firebase_auth = new FirebaseSimpleLogin F, (error, user) ->
      return alert(error)  if error
      if user
        current_user_id = user.uid
        facebook_id = user.id
        facebook_name = user.displayName
        F.child("users").child(user.uid).update
          name: user.displayName
          facebook_id: facebook_id
      window.on_auth_ready() if window.on_auth_ready
      window.auth_ready = true
  please_login: ->
    alert "Please login with facebook to complete this action!"
    firebase_auth.login "facebook",
      rememberMe: true



window.fb = ->
  args = Array::slice.call(arguments)
  str = args.shift()
  path = str.replace(/%/g, (m) ->
    args.shift()
  )
  F.child path
