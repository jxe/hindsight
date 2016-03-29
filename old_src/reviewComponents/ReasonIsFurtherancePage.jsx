import React from 'react'
import Subpage from './controls/Subpage.jsx'
import MultipleChoice from './controls/MultipleChoice.jsx'
import inEnglish from './inEnglish.js'
import {
  HowManyTimesSlider,
  HowOftenSlider,
  WhenDidYouFirstSlider,
} from './TimelineFormElements.jsx'
import TimelineUtil from '../collectiveExperience/timelineUtilities.js'

export default class ReasonIsFurtherancePage extends React.Component {
  render(){
    var {reasonId, cx, engagement} = this.props
    var { title } = cx.reasonData(reasonId)
    var payoffs = cx.getTrack(`${reasonId} fulfillments ${engagement.url}`)
    var atLeastOnePayoff = payoffs.occurrencesCount && payoffs.occurrencesCount != '0'
    var pass = { cx: cx, window: engagement.usage.window }
    var weeksOfUse = TimelineUtil.windowInWeeks(engagement.usage)
    var resource = engagement.url

    return <Subpage title={title}>
      <ul className="table-view">

        <MultipleChoice
          prompt="This is something I..."
          options={inEnglish.furtheranceHopes}
          onChange={x => inEnglish.setFurtheranceHopes(cx, reasonId, x)}
          currentOption={inEnglish.getFurtheranceHopes(cx, reasonId)}
        />

        <HowManyTimesSlider {...pass}
          text={`How many times over ${weeksOfUse} weeks of use has ${engagement.name} got me ${title}?`}
          for={`${reasonId} fulfillments ${engagement.url}`}
        />

        {
          atLeastOnePayoff &&
          <WhenDidYouFirstSlider {...pass}
            for={`${reasonId} fulfillments ${engagement.url}`}
            during={``}
            text="What long did it take the first time?"
          />
        }

        <MultipleChoice
          prompt="Given your results and the other ways you could have pursued them, has your investment been worth it?"
          options={inEnglish.reflections}
          onChange={x => inEnglish.setReflections(cx, resource, reasonId, x)}
          currentOption={inEnglish.getReflections(cx, resource, reasonId)}
        />
      </ul>
    </Subpage>
  }
}
