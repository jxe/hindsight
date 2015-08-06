import TimelineUtil from './timelineUtilities.js'
import fbAdaptor from './firebaseAdaptor.js'

export default class CollectiveExperience {
  live(cb) { return fbAdaptor.live(this.user, this, cb) }
  addConcern(x,y) { return fbAdaptor.addConcern(this.user, x,y) }
  setTrack(x,y) { return fbAdaptor.setTrack(this.user, x,y) }

  constructor(userID, userInfo){ this.user = userID }
  loaded(){ return this.reviews && this.vision && this.concerns }

  getTracks(reason, resource){
    return this.reviews[resource] && this.reviews[resource][reason] || {}
  }

  getTrack(forWhat){
    var [reason, track, resource] = forWhat.split(' ')
    if (!resource) return this.vision[reason] || {}
    var timeline = this.getTracks(reason, resource)
    return timeline[track] || {}
  }

  getConcerns(resource){
    return Object.keys(this.reviews[resource] || {})
  }

  getDisposition(reason, resource){
    var timeline = this.getTracks(reason, resource)
    return TimelineUtil.disposition(reason, timeline)
  }

  getCurrentValue(forWhat){
    return TimelineUtil.currentValue(this.getTrack(forWhat))
  }

  toggleValue(forWhat, window){
    var t = this.getTrack(forWhat)
    var v = TimelineUtil.currentValue(t)
    v = TimelineUtil.updateValue(t, !v)
    if (window) v.window = window
    this.setTrack(forWhat, v)
  }
}

CollectiveExperience.Timelines = TimelineUtil
