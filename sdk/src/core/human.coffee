window.firebase_auth = undefined


class window.Someone
  constructor: (@uid, data) ->
    for k, v of data
      this[k] = v
  learned: (x, rel, y, val) ->
    Learnings.set(@uid, x, rel, y, val)
    
  @usingThis: ->
    new Someone(current_user_id)

  
  # returns { value_id -> resource_url -> outcomes } 
  #  or { value_id -> outcomes }     iff options.resource specified
  #  or { resource_url -> outcomes } iff options.reason specified
  onResourceOutcomes: (obj, sel, options) ->
    options ||= {}  # .resource, .reason, .skip_abandoned
    obj.watch fb('wisdom/%/resources', @uid), 'value', sel, (snap) =>
      v = snap.val()
      result = {}
      for resource_key, resource_data of v
        url = Resource.from_firebase_path(resource_key)
        continue if options.resource and options.resource != url
        for value, outcomes of resource_data?.for || {}
          continue if (options.reason and options.reason != value) or (options.skip_abandoned and outcomes.abandonedFor)
          if options.resource
            result[value] = outcomes
          else
            result[value] ||= {}
            result[value][url] = outcomes
      if options.reason
        result[options.reason]
      else
        result
  
  
  onListsFor: (obj, sel, options) ->
    obj.watch fb('wisdom/%/%', @uid, options.value.id || options.value), 'value', sel, (snap) =>
      v = snap.val()
      result = {}
      for list, values of v
        for subvalue, _ of values
          result[list] ||= []
          result[list].push subvalue
      result

  'learnings': (obj, sel, value) ->
    obj.watch fb('learnings/%/%', @uid, value.id), 'value', 'learningsChanged', (snap) =>
      result = []
      v = snap.val()
      for rel, entries of v
        for subvalue, num of entries
          result.push [ value, rel, subvalue, num ]
      result
  
  onFavorites: (obj, sel) ->
    obj.watch fb('wisdom/%', @uid), 'value', sel, (snap) =>
      snap.val()
  
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
      window.current_user = new Someone(p.id, p)
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

window.Human = window.Someone