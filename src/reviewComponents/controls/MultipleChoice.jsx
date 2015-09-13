var React = require('react')

export default class MultipleChoice extends React.Component {
  acc(o){
    o[this.props.name] = this.props.currentOption
  }

  hideOptions(){
    this.setState({showOptions:false})
  }

  optionClicked(evt){
    this.setState({showOptions:false})
    this.props.onChange(evt.currentTarget.innerHTML)
  }

  constructor(props){
    super(props)
    this.state = { showOptions: true }
  }

  showOptions(){
    this.setState({showOptions:true})
  }

  render(){
    var { showOptions } = this.state
    var { prompt, currentOption, options } = this.props
    var inside = <span className="MultipleChoicePick">{currentOption}</span>
    if (showOptions) inside = <div className="segmented-control">{
      options.map( x =>
        <span className="control-item"
          onClick={this.optionClicked.bind(this)}
        >{x}</span>
      )
    }</div>

    return (
        <li
          className="table-view-cell"
          onClick={this.showOptions.bind(this)}
          >
          {prompt}
          {inside}
        </li>
    )
  }

}
