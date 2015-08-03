// ChromeUser

export default {

  withPerson(cb){
    if (localStorage.cachedPlusPerson){
      return cb(JSON.parse(localStorage.cachedPlusPerson))
    }
    this.withPersonUncached( (p) => {
      localStorage.cachedPlusPerson = JSON.stringify(p)
      cb(p)
    })
  },

  withPersonUncached(cb){
    chrome.identity.getAuthToken({interactive: true}, (authToken) => {
      fetch('https://www.googleapis.com/plus/v1/people/me', {
        headers: { 'Authorization': 'Bearer ' + authToken },
      }).then(r => r.json()).then(response => {
        cb({
          id: "plus:" + response.id,
          plusid: response.id,
          gender: response.gender,
          name: response.displayName,
          location: response.currentLocation,
          image: response.image && response.image.url,
          language: response.language,
          email: response.emails && response.emails[0] && response.emails[0].value
        })
      }).catch(ex => console.error(ex))
    })
  }
}





    // # firebase auth
    //
    // @withFirebasePerson: (cb) =>
    //   batshit.setup_firebase()
    //   window.firebase_auth = new FirebaseSimpleLogin F, (error, response) ->
    //     return alert(error) if error
    //     return unless response
    //     cb \
    //       firebase: response,
    //       id: response.uid,
    //       facebook_id: response.id,
    //       name: response.displayName,
    //       location: response.location?.name || "unknown location",
    //       image: response.picture?.data?.url || "https://graph.facebook.com/#{response.id}/picture"
    //       # gender: response.gender
    //       # location: response.currentLocation
    //       # language: response.language
    //       # email: response.emails?[0]?.value
    //
    // @withPossiblyCachedFirebasePerson: (cb) =>
    //   if localStorage.cachedFirebasePerson
    //     p = JSON.parse(localStorage.cachedFirebasePerson)
    //     F.auth(p.firebase.firebaseAuthToken)
    //     return cb(p)
    //   else
    //     @withFirebasePerson (p) ->
    //       localStorage.cachedFirebasePerson = JSON.stringify p
    //       F.auth(p.firebase.firebaseAuthToken)
    //       cb p
