import React from 'react'

// data sources
import CollectiveExperience from '../collectiveExperience/collectiveExperience.js'
import TimelineUtil from '../collectiveExperience/timelineUtilities.js'

// subwidgets
import ExpandingList from './ExpandingList.jsx'
import CXReasonEntryField from '../reasonComponents/CXReasonEntryField.jsx'
import DeliversEquipmentForm from './DeliversEquipmentForm.jsx'
import FeaturesActivityForm from './FeaturesActivityForm.jsx'



export default class CXReview extends React.Component {
  constructor(props){ super(props); this.state = {} }

  render(){
    var { cx, engagement } = this.props
    var { addition } = this.state
    if (!cx.loaded()) return <div>Loading</div>
    var concerns = Object.keys(cx.concerns).map(k => cx.concerns[k])
    var commonConcerns = concerns.slice(0,3)
    var addedConcernIDs = cx.getConcerns(engagement.url)
    var usageSummary = <div dangerouslySetInnerHTML={{
      __html: TimelineUtil.htmlSummary(engagement.usage)
    }} />
    var body = addition ? this.renderPromptBox() : this.renderExpandingList()

    return <div className="vreview">
      <header className="bar bar-nav bar-extended">
        <CXReasonEntryField
          focused={addedConcernIDs.length == 0}
          placeholder={"Why " + engagement.name + "?"}
          commonReasons={commonConcerns}
          allReasons={concerns}
          excludeReasons={addedConcernIDs}
          onAdded={this.onAdded.bind(this)} />
      </header>
      <div className="content column">
        {body}
        <div className="verticalSpace"></div>
        {usageSummary}
      </div>
    </div>
  }

  renderExpandingList(){
    var {cx, engagement} = this.props
    var pass = { cx: cx, engagement: engagement }
    var addedConcernIDs = cx.getConcerns(engagement.url)
    var rowForReason = x => <ReasonRow key={x} reasonId={x} {...pass} />
    var expandedRow =  x => <ReasonForm {...pass} reasonId={x} />

    return <ExpandingList ref='list' expander={expandedRow}>
      {addedConcernIDs.map(rowForReason)}
    </ExpandingList>
  }

  renderPromptBox(){
    var {addition} = this.state
    if (!addition) return
    return <div className="promptBox">
      <h3>How would you describe “{addition}”?</h3>
      <p>
        This is
        <a onClick={() => this.addConcern(`activity/${addition}`)}>
          an activity
        </a>
        I'll do for hours each week
      </p>
      <p>
        This is
        <a onClick={() => this.addConcern(`equipment/${addition}`)}>
          a good thing in myself, my community, or my environment
        </a>,
        which makes new activities possible but is not an activity in itself
      </p>
    </div>
  }

  onAdded(str){
    if (str.id){
      var { cx, engagement } = this.props
      cx.addConcern(engagement.url, str.id)
      this.justAddedReason = str.id
    } else {
      this.setState({ addition: str })
    }
  }

  componentDidUpdate(){
    if (!this.justAddedReason) return
    this.refs.list.show(this.justAddedReason) // show it expanded
    this.justAddedReason = null
  }

  addConcern(str){
    var { cx, engagement } = this.props
    cx.addConcern(engagement.url, str)
    this.justAddedReason = str
    this.setState({ addition: null })
  }
}



class ReasonRow extends React.Component {
  render(){
    var { reasonId, cx, engagement, onClick } = this.props
    var [ type, reasonName ] = reasonId.split('/')
    var { icon, phrase, color } = cx.getDisposition(reasonId, engagement.url)

    return <li className="table-view-cell signalrow" onClick={onClick}>
      <h3 className={color}>
        <span className={`icon ${icon}`}></span>
        <b>{phrase}</b>
      </h3>
      <span className={`-hsloz ${color}`}>
        <b>{reasonName}</b>
      </span>
    </li>
  }
}


class ReasonForm extends React.Component {
  render(){
    var [ type, name ] = this.props.reasonId.split('/')
    return (type == 'equipment') ?
      <DeliversEquipmentForm {...this.props} /> :
      <FeaturesActivityForm  {...this.props} />
  }
}





// export default class CXReview extends React.Component {
//
//   constructor(props){
//     super(props)
//     this.state = { cx: new CollectiveExperience(props.userID) }
//   }
//
//   componentWillMount(){
//     this.state.cx.live(() => this.setState({ cx: this.state.cx }) )
//   }
//
//   render(){
//     var { cx } = this.state
//     if (!cx.loaded()) return <div>Loading</div>;
//     return <ReviewView cx={cx} engagement={this.props.engagement} />
//   }
//
//   static renderIn(elem, userID, engagement){
//     React.render(<this engagement={engagement} userID={userID} />, elem)
//   }
//
// }
//




  //
  // outcomeClicked: (ev) =>
  //   tag = $(ev.target).pattr 'reason'
  //   if $(ev.target).hasClass('icon-close')
  //     # return unless confirm('Sure?')
  //     @currentObservations.remove(tag)
  //   else
  //     @editOutcome(tag) if tag
  //
  // onChoseInclination: (r) =>
  //   new ActivityClaimModal(@engagement, r, this)
  //
  // editOutcome: (tag) =>
  //   new ActivityClaimModal(@engagement, Inclination.fromId(tag), this)
  //
  // hintClicked: (ev) =>
  //   id = $(ev.target).pattr('reason')
  //   new ActivityClaimModal(@engagement, Inclination.fromId(id), this) if id


    // observationsChanged: (o) ->
    //   @redrawHints()
    //   @hints.toggle( arr.length < 4 )


    // inject: (el) ->
    //   $(el).html(new Pager(this))


    // initialize: (engagement, previousReview) ->
    //   @bind observationsChanged: Observations.live(current_user_id, @engagement)
    //   # fb('wisdom/%/promises', @engagement.id).once 'value', (snap) =>
    //   #   v = snap.val()
    //   #   if v
    //   #     @commonMotivations = Object.keys(v)
    //   #   @redrawHints()


  // prompt: (text, cb) =>
  //   @promptBox.show().html(text).click(cb)
  //
  // thanks: =>
  //   @promptBox.html("Thanks")
  //   setTimeout((=> @promptBox.hide()), 1000)


// ReviewData =
//   valence: (d) =>
//     return 'positive' if d.expressedVia or d.deliveredVia
//     return 'negative' if d.pursuedVia
//     return 'neutral'
//
//   infixPhrase: (d) ->
//     return 'led to' if d.deliveredVia
//     return 'hasn\'t led to' if d.pursuedVia
//     return 'regularly used for' if d.expressedVia
//     # abandoned for
//     # trying for
//
//   lozenge: (value, valence = 'neutral') =>
//     $$$ ->
//       @span reason: value, class: "-hsloz #{valence}", =>
//         @span ''
//         @b value



        //   # yourGoals: =>
        //   #   @pushPage new PersonExperiencesInspector()
        //
        //
        //   # redrawHints: =>
        //   #   return unless @currentObservations
        //   #   keys = (x for x in @commonMotivations when !@currentObservations.relatives[x])
        //   #   return unless keys and keys.length
        //   #
        //   #   @hints.html $$ ->
        //   #     @div =>
        //   #       @p "Others said:"
        //   #       for id in keys
        //   #         @a reason: id, Inclination.fromId(id).name
        //   #         @raw " &nbsp; "
        //   #
        //   # @fromResourceAndUser: (r, uid, is_child) ->
        //   #   p = r.firebase_path()
        //   #   new ObservationsEditor
        //   #     url: r.canonUrl,
        //   #     resource: r,
        //   #     name: r.name(),
        //   #     is_child: is_child
        //
        //
        // #  @sort_tags: (tags) ->
        // #    keys = Object.keys(tags).sort()
        // #    result = []
        // #    # add goingWell, then goingPoorly, then other
        // #    for k in keys
        // #      result.push(k) if tags[k]?.assessment == 'delivered'
        // #    for k in keys
        // #      result.push(k) if tags[k]?.assessment != 'delivered'
        // ##    for k in keys
        // ##      result.push(k) if !tags[k]?.going
        // #    result
        // #
        //






// class window.ActivityClaimModal extends Modal
//   initialize: (@b, @a, @delegate) ->
//     @openIn(delegate)
//     @bind observationsChanged: Observations.live(current_user_id, @a)
//
//   @content: (b, a) ->
//     [ aloz, bloz ] = [ a.lozenge(), b.lozenge() ]
//     @div class: 'hovermodal', =>
//       @div class: 'content-padded', =>
//          @p =>
//             @raw "Is #{bloz} good for #{aloz}?"
//          @segment 'goodFor', {yes:'Yes', no:'No', unknown:'Dont know yet'}, 'unknown'
//          @p click: 'goal', =>
//             @raw "How's your search for #{aloz}, generally?"
//          @segment 'search', {enjoying:'Solved', seeking:'Still looking', abandoned:'Moved on'}, 'seeking'
//          @div outlet: 'thirdQuestion'
//          @button class: 'btn btn-block', click: 'done', "Done"
//
//   goal: =>
//     @parent.pushPage new ReasonEditor(@a)
//     @close()
//
//   goodForChanged: (picked) =>
//      @goodFor = picked
//      console.log "gfc: perusal: ", @perusal, "goodfor", @goodFor
//      current_user.thinksIsGoodFor(@b, @a, picked)
//      # @redisplay()
//
//   searchChanged: (picked) =>
//      @perusal = picked
//      console.log "sc: perusal: ", @perusal, "goodfor", @goodFor
//      # @redisplay()
//      current_user.setPerusalState(@a, @perusal)
//
//   observationsChanged: (o) ->
//     @perusal = o.pursualState(@a)
//     @goodFor = o.isGoodFor(@b)
//     console.log "oc: perusal: ", @perusal, "goodfor", @goodFor
//     @redisplay()
//
//   redisplay: =>
//      @find("[tabname='#{@goodFor}']").addClassAmongSiblings('active')
//      @find("[tabname='#{@perusal}']").addClassAmongSiblings('active')
//
//      if @perusal == 'enjoying' and @goodFor == 'no'
//         # what solved?
//      else if @perusal == 'abandoned'
//         # what's the new goal?
//      else
//         @thirdQuestion.empty()
//
//   done: =>
//     if @perusal == 'abandoned'
//       new MoreImportantGoodCollector(@delegate, value: @a)
//     else if @goodFor == 'no'
//       new BetterActivityCollector(@delegate, value: @a)
//     @close()


// class window.MoreImportantGoodCollector extends Modal
//   initialize: (@justifier, @options) ->
//     @justifier.prompt "What is more important to you now than #{@options.value.lozenge()}?", =>
//       @openIn(@justifier)
//   @content: (justifier, options) ->
//     @div class: 'hovermodal chilllozenges MoreImportantGoodCollector', =>
//       @div class: 'content-padded', =>
//         @h4 =>
//           @raw "Add a goal that trumps #{options.value.lozenge()}"
//       @subview 'search', new InclinationSearchBox(hint: "add a goal...")
//   onChoseInclination: (v) =>
//     current_user.observes v, "trumps", @options.value, 1.0
//     @close()
//     @justifier.thanks()
//
// class window.BetterActivityCollector extends Modal
//   initialize: (@justifier, @options) ->
//     @justifier.prompt "What does help, with #{@options.value.lozenge()}?", =>
//       @openIn(@justifier)
//   @content: (justifier, options) ->
//     @div class: 'hovermodal chilllozenges BetterActivityCollector', =>
//       @div class: 'content-padded', =>
//         @h4 =>
//           @raw "Add a better activity for #{options.value.lozenge()}"
//       @subview 'search', new InclinationSearchBox(hint: "add an activity...")
//   onChoseInclination: (v) =>
//     current_user.observes v, "delivers", @options.value, 1.0
//     @close()
//     @justifier.thanks()



// class window.ObservationMenu extends MenuModal
//   initialize: ->
//     [ @aloz, @bloz ] = [ @a.lozenge(), @b.lozenge() ]
//     super()
//   clicked: (ev) =>
//     exp = $(ev.target).pattr('id')
//     [ rel, val ] = exp.split(',')
//     current_user.observes @b, rel, @a, Number(val)
//     @close()
//     @afterClick(rel, val) if @afterClick
//
//
//
// class window.GoodObservationMenu extends ObservationMenu
//   initialize: (@b, @a, @rel) ->
//     super()
//     @prompt.html "Why do people turn to #{@bloz} for #{@aloz}?"
//
//   options: =>
//     [
//       ['delivers,1', "<b>It works.</b>. I've found #{@bloz} works for #{@aloz}.", 'check'],
//       ['expressedas,1', "<b>It's part of it.</b> #{@bloz} is part of #{@aloz}.", 'list']
//     ]
//
