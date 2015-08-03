import React from 'react'
import ReviewContainer from './src/components/CXReview.jsx'

import css from './src/css.js'
css('styles')
css('vendor/ratchet/css/ratchet')

var engagement = {
  url: 'https://facebook.com',
  name: 'facebook',
  window: [2813123,128739123],
  length: 'a million days'
}

React.render(
  <CXReview engagement={engagement} userID="joe" />,
  document.body
)





// import * as sampleData from './sampleData.js'
// import RegularTimeSlider from './src/domain/RegularTimeSlider.jsx'
// <RegularTimeSlider
//   for="activities/laughter usage http://facebook.com"
//   cx={handle}
// />,
