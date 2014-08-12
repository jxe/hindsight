window.firebase_auth = undefined


class window.Someone
  constructor: (@uid) ->
  @usingThis: ->
    new Someone(current_user_id)
  
  onOutcomes: (view, cb) ->
    view.sub fb('experience/%/resources', @uid), 'value', (snap) =>
      v = snap.val()
      result = {}
      for resource_key, value_outcomes of v
        for value, outcome of value_outcomes?.for
          result[value] ||= {}
          url = Resource.from_firebase_path(resource_key)
          result[value][url] = outcome
      cb(result)
  
  
  # auth
  
  @loggedIn: (cb) =>
    batshit.setup_firebase()
    login_fn = if localStorage.cachedPlusPerson or window?.chrome?.identity
      @withPossiblyCachedPlusPerson
    else
      @withPossiblyCachedFirebasePerson
    login_fn (p) =>
      window.current_user_id = p.id
      window.current_user = p
      F.child("users").child(current_user_id).update current_user
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
        image: "https://graph.facebook.com/#{response.id}/picture"
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
