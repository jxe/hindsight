import Firebase from 'firebase'
import Timelines from './timelines.js'

var F = new Firebase('https://lifestyles.firebaseio.com')


export default class CollectiveExperience {

  // lifecycle

  // window.current_user_id = p.id
  // F.child("users").child(p.id).update p
  constructor(userID, userInfo){ this.user = userID }

  live(cb){
    F.child('concerns').on('value', snap => {
      this.concerns = snap.val() || {}
    })
    F.child('profiles').child(this.user).on('value', snap => {
      // console.log('profiles updated')
      var data = snap.val() || {}
      this.reviews = data.reviews || {}
      this.vision = data.vision || {}
      cb(this)
    })
  }

  loaded(){
    console.log('loaded?', this)
    return this.reviews && this.vision && this.concerns
  }


  // accessing

  getTracks(reason, resource){
    var r = encodeURIComponent(resource).replace(/\./g, '%2E')
    var review = this.reviews[r]
    if (!review) return {}
    return review[encodeURIComponent(reason)] || {}
  }

  getTrack(forWhat){
    var [reason, track, resource] = forWhat.split(' ')
    if (resource){
      var timeline = this.getTracks(reason, resource)
      return timeline[track] || {}
    } else {
      return this.vision[encodeURIComponent(reason)] || {}
    }
  }

  getConcerns(resource){
    var r = encodeURIComponent(resource).replace(/\./g, '%2E')
    return Object.keys(this.reviews[r] || {}).map(decodeURIComponent)
  }


  // calculated access

  getDisposition(reason, resource){
    var timeline = this.getTracks(reason, resource)
    return Timelines.disposition(reason, timeline)
  }

  getCurrentValue(forWhat){
    return Timelines.currentValue(this.getTrack(forWhat))
  }


  // writes

  addConcern(resource, concern){
    var encodedConcern = encodeURIComponent(concern)
    var r = encodeURIComponent(resource).replace(/\./g, '%2E')
    F.child('profiles').child(this.user).child('reviews').child(r).child(encodedConcern).child('added').set(true)
    var [ concernType, concernTitle ] = concern.split('/')
    F.child('concerns').child(encodedConcern).update({
      id: concern,
      type: concernType,
      title: concernTitle
    })
  }

  toggleValue(forWhat, window){
    var t = this.getTrack(forWhat)
    var v = Timelines.currentValue(t)
    v = Timelines.updateValue(t, !v)
    if (window) v.window = window
    this.setTrack(forWhat, v)
  }

  setTrack(forWhat, data){
    var [reason, track, resource] = forWhat.split(' ')
    var base = F.child('profiles').child(this.user)
    if (resource){
      var r = encodeURIComponent(resource).replace(/\./g, '%2E')
      base = base.child('reviews').child(r).child(encodeURIComponent(reason)).child(track)
    } else {
      base = base.child('vision').child(encodeURIComponent(reason))
    }
    base.update(data)
  }

}


CollectiveExperience.Timelines = Timelines
