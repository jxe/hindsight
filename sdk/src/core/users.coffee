window.firebase_auth = undefined

class window.User
  constructor: (@uid, data) ->
    for k, v of data
      this[k] = v

  observes: (x, rel, y, val) ->
    Observations.set(@uid, x, rel, y, val)
  unobserves: (x, rel, y) ->
    Observations.unset(@uid, x, rel, y)

  claims: (x, rel, y) ->
    inverse_rel = if rel.match(/^what/) then rel.replace('what', '') else "what#{rel}"
    fb('goods/%/%/%', x.id, rel, y.id).set true
    fb('goods/%/%/%', y.id, inverse_rel, x.id).set true

  observations: (obj, sel, value) ->
    obj.watch fb('observations/%/%', @uid, value.id), 'value', 'observationsChanged', (snap) =>
      result = []
      v = snap.val()
      for rel, entries of v
        for subvalue, num of entries
          result.push [ value, rel, subvalue, num ]
      result
  

  # auth
  
  @loggedIn: (cb) =>
    batshit.setup_firebase()
    login_fn = if localStorage.cachedPlusPerson or window?.chrome?.identity
      @withPossiblyCachedPlusPerson
    else
      @withPossiblyCachedFirebasePerson
    login_fn (p) =>
      delete p.firebase
      window.current_user_id = p.id
      window.current_user = new User(p.id, p)
      F.child("users").child(current_user_id).update p
      cb() if cb


  # plus
  
  @withPlusPerson: (cb) =>
    console.log 'trying for identity'
    chrome.identity.getAuthToken {interactive: true}, (authToken) ->
      console.log 'identity found'
      $.ajax \
        url: 'https://www.googleapis.com/plus/v1/people/me',
        headers: { 'Authorization': 'Bearer ' + authToken },
        success: (response) ->
          console.log 'calling person callback' 
          cb \
            id: "plus:" + response.id,
            plusid: response.id,
            gender: response.gender,
            name: response.displayName,
            location: response.currentLocation,
            image: response.image?.url,
            language: response.language,
            email: response.emails?[0]?.value
        error: (error) -> console.error error

  @withPossiblyCachedPlusPerson: (cb) =>
    return cb(JSON.parse(localStorage.cachedPlusPerson)) if localStorage.cachedPlusPerson
    @withPlusPerson (p) ->
      localStorage.cachedPlusPerson = JSON.stringify p
      cb p
      

  # firebase auth

  @withFirebasePerson: (cb) =>
    batshit.setup_firebase()
    window.firebase_auth = new FirebaseSimpleLogin F, (error, response) ->
      return alert(error) if error
      return unless response 
      cb \
        firebase: response,
        id: response.uid,
        facebook_id: response.id,
        name: response.displayName,
        location: response.location?.name,
        image: response.picture?.data?.url || "https://graph.facebook.com/#{response.id}/picture"
        # gender: response.gender
        # location: response.currentLocation
        # language: response.language
        # email: response.emails?[0]?.value
  
  @withPossiblyCachedFirebasePerson: (cb) =>
    if localStorage.cachedFirebasePerson
      p = JSON.parse(localStorage.cachedFirebasePerson)
      F.auth(p.firebase.firebaseAuthToken)
      return cb(p)
    else
      @withFirebasePerson (p) ->
        localStorage.cachedFirebasePerson = JSON.stringify p
        F.auth(p.firebase.firebaseAuthToken)
        cb p
  
  @please_login: ->
    alert "Please login with facebook to complete this action!"
    window.firebase_auth.login "facebook",
      rememberMe: true
