import Firebase from 'firebase'
var F = new Firebase('https://lifestyles.firebaseio.com')
function e(x){ return encodeURIComponent(x).replace(/\./g, '%2E') }
function d(x){
  if (!x || x.constructor != Object) return x;
  return Object.keys(x).reduce((result, k) => {
    result[decodeURIComponent(k)] = d(x[k])
    return result
  }, {})
}

export default {
  live(u, cx, cb){
    this.fbReasons().on('value', snap => {
      cx.reasons = d(snap.val()||{})
    })
    F.child(`profiles/${u}`).on('value', snap => {
      var data = snap.val() || {}
      cx.reviews = d(data.reviews || {})
      cx.hopes = d(data.hopes || {})
      console.log('loaded reviews', cx.reviews)
      cb(this)
    })
  },

  addReasonWithId(u, resource, id){
    this.fbProfile(u,`reviews/${e(resource)}/${e(id)}/_`).set(true)
  },

  addReason(u,resource, type, title){
    var id = e(`${type}/${title}`)
    this.fbProfile(u,`reviews/${e(resource)}/${e(id)}/_`).set(true)
    this.fbReasons(e(id)).update({ id: id, type: type, title: title })
    return id
  },

  setTrack(u,forWhat, data){
    var [reason, track, resource] = forWhat.split(' ')
    if (resource) this.fbProfile(u,`reviews/${e(resource)}/${e(reason)}/${track}`).update(data)
    else this.fbProfile(u,`hopes/${e(reason)}`).update(data)
  },


  fbReasons(x=''){ return F.child(`reasons/${x}`) },
  fbProfile(user, x){ return F.child(`profiles/${user}/${x}`)},
}
