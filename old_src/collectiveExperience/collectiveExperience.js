import TimelineUtil from './timelineUtilities.js'
import fbAdaptor from './firebaseAdaptor.js'

export default class CollectiveExperience {
  setTrack(x,y) { return fbAdaptor.setTrack(this.user, x,y) }
  constructor(userID, userInfo){ this.user = userID }
  loaded(){ return this.reviews && this.hopes && this.reasons }

  addReasonWithId(resource, id){
    console.log('addReasonWithId', id)
    return fbAdaptor.addReasonWithId(this.user, resource, id)
  }

  addReason(resource, type, title) {
    return fbAdaptor.addReason(this.user, resource, type, title)
  }

  reasonData(id){
    return this.reasons[id] || { title: 'unknown' }
  }

  live(cb) {
    return fbAdaptor.live(this.user, this, () => {
      if (this.reasons) this.reindexReasons()
      cb(this)
    })
  }

  reindexReasons(){
    if (this.indexedReasons == this.reasons) return
    this.indexedReasons = this.reasons
    var terms = this.terms = {}
    for (var reasonId in this.reasons){
      var c = this.reasons[reasonId]
      if (!terms[c.title]) terms[c.title] = []
      var x = terms[c.title]
      console.log('terms[c.title]', x, c.title, x.push)
      x.push([c.id, 'is', c.title, c.title]);

      // add all aliases, hyper/hyponyms, and payoffs to the terms database
      (['syn', 'hypo', 'hyper', 'yield']).forEach( rel => {
        if (c[rel]) c[rel].forEach( x => {
          if (!terms[x]) terms[x] = []
          terms[x].push([c.id, rel, x, c.title])
        })
      })
    }
    this.allTerms = Object.keys(this.terms)
  }

  completions(str){
    console.log('allTerms', this.allTerms, this)
    var matches = this.allTerms.filter( x => x.indexOf(str) != -1 ).slice(0,10)
    return matches.map( m => this.terms[m] ).reduce( (a, b) => a.concat(b), [] );
  }

  commonReasons(resource, type){
    return []
  }

  getTracks(reason, resource){
    return this.reviews[resource] && this.reviews[resource][reason] || {}
  }

  getTrack(forWhat){
    var [reason, track, resource] = forWhat.split(' ')
    if (!resource) return this.hopes[reason] || {}
    var timeline = this.getTracks(reason, resource)
    return timeline[track] || {}
  }

  getReasons(resource){
    return Object.keys(this.reviews[resource] || {})
  }

  getCurrentValue(forWhat){
    return TimelineUtil.currentValue(this.getTrack(forWhat))
  }
}

CollectiveExperience.Timelines = TimelineUtil
