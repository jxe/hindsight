import React from 'react'
import Subpage from './controls/Subpage.jsx'
import MultipleChoice from './controls/MultipleChoice.jsx'
import { HowOftenSlider } from './TimelineFormElements.jsx'
import inEnglish from './inEnglish.js'

export default class ReasonIsExperiencePage extends React.Component {
  render(){
    var {reasonId, cx, engagement} = this.props
    var pass = { cx: cx, window: engagement.usage.window }
    var { title } = cx.reasonData(reasonId)
    var resource = engagement.url
    var wantMoreOften = (inEnglish.getHopes(cx, reasonId) == 'more often')

    return <Subpage title={title}>
      <ul className="table-view">

        <MultipleChoice
          prompt="I want to experience this..."
          options={inEnglish.hopes}
          onChange={x => inEnglish.setHopes(cx, reasonId, x)}
          currentOption={inEnglish.getHopes(cx, reasonId)}
        />

        {wantMoreOften && <HowOftenSlider {...pass}
          for={`${reasonId} hopes`}
          text="I want to spend"
          unit="hrs/wk"
        />}

        <HowOftenSlider {...pass}
          for={`${reasonId} fulfillments ${engagement.url}`}
          during={engagement.usage}
          text={`During how much of ${engagement.name} are you ${title}?`}
          unit="hrs/wk"
        />

        <MultipleChoice
          prompt="Was this a good choice for getting this experience?"
          options={inEnglish.reflections}
          onChange={x => inEnglish.setReflections(cx, resource, reasonId, x)}
          currentOption={inEnglish.getReflections(cx, resource, reasonId)}
        />

      </ul>
    </Subpage>
  }
}
