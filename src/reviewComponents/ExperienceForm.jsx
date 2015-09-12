import React from 'react'
import {
  HowOftenSlider,
  AreYouNowToggle
} from './TimelineFormElements.jsx'


export default class ExperienceForm extends React.Component {
  render(){
    var {reasonId, cx, engagement} = this.props
    var [ reasonType, reasonName ] = reasonId.split('/')
    var pass = { cx: cx, window: engagement.usage.window }

    return <div className="expansion">
      <HowOftenSlider {...pass}
        for={`${reasonId} hopes`}
        text="I want to spend"
        unit="hrs/wk"
      />
      <HowOftenSlider {...pass}
        for={`${reasonId} fulfillments ${engagement.url}`}
        during={engagement.usage}
        text={`During how much of ${engagement.name} are you ${reasonName}?`}
        unit="hrs/wk"
      />
      <AreYouNowToggle {...pass}
        reversed={true}
        for={`${reasonId} reflections ${engagement.url}`}
        text={`There are alternatives to ${engagement.name} that are more compatible with ${reasonName} and these would have been better for me.`}
      />
    </div>
  }
}
