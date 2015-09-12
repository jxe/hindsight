var React = require('react')

export default class AutocompleteField extends React.Component {

  constructor(props){
    super(props)
    this.state = { focused: props.focused }
  }

  componentDidMount(){
    if (this.state.focused) React.findDOMNode(this.refs.input).focus()
  }

  onFocus(){
    this.setState({focused:true})
  }

  onBlur(){
    console.log('onBlur')
    // this.setState({focused:false})
  }

  render(){
    return <div className="AutocompleteField">
      <div className="entry">
        <input
          ref="input"
          tabIndex="-1"
          value={this.state.value}
          placeholder={this.props.placeholder}
          onChange={this.onChange.bind(this)}
          onKeyDown={this.onKeyDown.bind(this)}
          onFocus={this.onFocus.bind(this)}
          onBlur={this.onBlur.bind(this)}
        />
      </div>
      {this.renderSuggestions()}
    </div>
  }

  renderSuggestions(){
    var completions = this.props.completions(this.state.value)
    if (!completions || !completions.length) return;
    if (!this.state.focused) return;

    return <div className="table-view suggestions">{
      completions.map( e => {
        return React.cloneElement(e, {onClick: this.onClick.bind(this, e.props.obj)})
      })
    }</div>
  }

  onClick(obj, evt){
    console.log('onClick', obj, evt)
    this.props.onChange(evt.currentTarget, obj)
    this.clear()
  }

  onChange(evt){
    this.setState({value: evt.currentTarget.value})
  }

  clear(){
    this.setState({value: ''})
  }

  onKeyDown(evt){
    if (evt.key == 'Enter' && this.state.value){
      this.props.onChange(this.state.value, null)
      this.clear()
    }
  }

}



class TestAutocompleteView extends React.Component {

  render(){
    let completions = x => {
      return ['Alpha', 'Beta', 'Gamma'].map(x => {
        <li>{x}</li>
      })
    }

    return <AutocompleteField
      placeholder="Type something"
      completions={completions}
      onChange={this.onChange}
      />
  }

}
