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
    this.fbConcerns().on('value', snap => {
      cx.concerns = d(snap.val()||{})
    })
    F.child(`profiles/${u}`).on('value', snap => {
      var data = snap.val() || {}
      cx.reviews = d(data.reviews || {})
      cx.vision = d(data.vision || {})
      cb(this)
    })
  },

  addConcern(u,resource, concern){
    var c = concern.split('/')
    this.fbProfile(u,`reviews/${e(resource)}/${e(concern)}/_`).set(true)
    this.fbConcerns(e(concern)).update({ id: concern, type: c[0], title: c[1] })
  },

  setTrack(u,forWhat, data){
    var [reason, track, resource] = forWhat.split(' ')
    if (resource) this.fbProfile(u,`reviews/${e(resource)}/${e(reason)}/${track}`).update(data)
    else this.fbProfile(u,`vision/${e(reason)}`).update(data)
  },


  fbConcerns(x=''){ return F.child(`concerns/${x}`) },
  fbProfile(user, x){ return F.child(`profiles/${user}/${x}`)},
}
