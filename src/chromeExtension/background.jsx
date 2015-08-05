
import React from 'react'
import LibUsage from '../usageTracker/libusage.js'
import ChromeUser from './chromeUser.js'
import CXReview from '../reviewComponent/CXReview.jsx'
import CollectiveExperience from '../collectiveExperience/collectiveExperience.js'

var cx;

window.onload = () => LibUsage.instrumentChrome()
window.renderReviewIn = el => {
  ChromeUser.withPerson( p => {
    LibUsage.withEngagementForCurrentURL( e => {
      if (!cx) cx = new CollectiveExperience(p.id, p)
      console.log('original cx', cx)
      cx.live(() => {
        console.log('live cx', cx)
        React.render( <CXReview cx={cx} engagement={e} />, el )
      })
    })
  })
}
