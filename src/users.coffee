window.firebase_auth = undefined

class window.User
  constructor: (@uid, data) ->
    for k, v of data
      this[k] = v

  thinksIsGoodFor: (x, y, yes_no_maybe) ->
    switch yes_no_maybe
       when 'yes'
          Observations.set(@uid, x, "delivers", y, 1.0)
       when 'no'
          Observations.set(@uid, x, "delivers", y, 0.0)
       when 'unknown'
          Observations.set(@uid, y, "drives", x, 1.0)

  observes: (x, rel, y, val) ->
    Observations.set(@uid, x, rel, y, val)
  unobserves: (x, rel, y) ->
    Observations.unset(@uid, x, rel, y)

  setPerusalState: (x, which) ->
    switch which
      when 'seeking'
        @values(x, true)
        @seeks(x, true)
      when 'enjoying'
        @values(x, true)
        @seeks(x, false)
      when 'abandoned'
        @values(x, false)
        @seeks(x, false)
  values: (x, val) ->
    Timeframe.set(fb('claims/%/%/%', @uid, x.id || x, 'valued'), val)
  seeks: (x, val) ->
    Timeframe.set(fb('claims/%/%/%', @uid, x.id || x, 'sought'), val)
  

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
        location: response.location?.name || "unknown location",
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
