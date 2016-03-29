let ReactDOM = require('react-dom'),
       React = require('react'),
   Component = React.Component

import Activities from 'chrome-activities'

let { NavBar, NavButton, Title } = require('react-ratchet')

import ReasonBrowser from 'reasons/browser.jsx'
import AssessmentCard from 'reasons/activities/card.jsx'


Activities.monitorActivities(a => {

  console.log('current activity', a)
  // adjustEyeball

  // a.elapsed

  // no review:
  //   clear => not time to review yet, and no review
  //   side eye => time to review!
  // review:
  //   red => you don't like this site
  //   heart => you like this site
})


window.showPopup = el => {
  withGooglePlusIdentity( p => {
    Activities.withUnreviewed(all => {
      ReactDOM.render(<Popup user={p} newActivities={all} />, el )
    })
  })
}

class Popup extends Component {
  render(){
    if (this.state && this.state.show == 'reasons'){
      return <ReasonBrowser onClose={()=>this.setState({show:false})}/>
    } else {
      return <ReviewPanel {...this.props} compose={()=>this.setState({show:'reasons'})} />
    }
  }
}

const ReviewPanel = (props) => (
  <div>
    <NavBar>
      <NavButton right icon="compose" onClick={props.compose} />
      <Title>Assess!</Title>
    </NavBar>
    <div className="content">{
        props.newActivities.map(a => (
          <AssessmentCard user={props.user} activity={a}/>
        ))
      }</div>
  </div>
)




function withGooglePlusIdentity(cb){
  if (localStorage.plusID) return cb(JSON.parse(localStorage.plusID))
  chrome.identity.getAuthToken({interactive: true}, (authToken) => {
    fetch('https://www.googleapis.com/plus/v1/people/me', {
      headers: { 'Authorization': 'Bearer ' + authToken },
    }).then(r => r.json()).then(response => {
      if (!response || !response.id) return;
      var identity = {
        id: "plus:" + response.id,
        plusid: response.id,
        gender: response.gender,
        name: response.displayName,
        location: response.currentLocation,
        image: response.image && response.image.url,
        language: response.language,
        email: response.emails && response.emails[0] && response.emails[0].value
      }
      localStorage.plusID = JSON.stringify(identity)
      cb(identity)
    }).catch(ex => console.error(ex))
  })
}








    //
    // chrome.tabs.query({active:true, currentWindow:true}, tabs => {
    //   var url = tabs[0].url
    //   url = cleanURL(url)
    //   var timelines = BrowserHistory.getTimelines(url)
    //   var e = {
    //     url: url,
    //     name: url,
    //     usage: timelines.directUsage,
    //     indirectUsage: timelines.indirectUsage,
    //     favIconUrl: tabs[0].favIconUrl
    //   }
    //
    //     <span>{p.id}</span>
    //     <span>{url}</span>
    //     <span>
    //       {Timelines.getMedianSecondsPerWeek(timelines.directUsage)}
    //     </span>
    //     <span>
    //       {Timelines.getMedianSecondsPerWeek(timelines.indirectUsage)}
    //     </span>
    //     <UsageView engagement={e} />
        // <ReasonsListView
        //   userId={p.id}
        //   engagement={e}
        //   usageSummary={ <ActionSummary engagement={e} /> }
        // />





// reasons browsing



// assessments





// import BrowserHistory from '../../src/assessment/browserHistory'
// import Timelines from '../../src/assessment/timelines'
// import UsageView from '../../src/assessment/usageView'

// import Assessment from '../../src/assessment'
// import ReasonsListView from 'reasons/listView'








//////////////////////////////////////
//////// PART OF HINDSIGHT ///////////
//////////////////////////////////////








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
