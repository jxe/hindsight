import React from 'react'
import AutocompleteField from './AutocompleteField.jsx'

export default class CXReasonEntryField extends React.Component {

  emptyCompletions(){
    var { commonReasons, excludeReasons } = this.props
    return commonReasons.filter( x => {
      return excludeReasons.indexOf(x.id) == -1
    }).map(
      x => <li obj={x}> Was it {x.title}? </li>
    )
  }

  completions(val){
    if (!val) return this.emptyCompletions();

    var { allReasons, excludeReasons } = this.props
    return allReasons.filter( x=> {
      if (excludeReasons.indexOf(x.id) != -1) return false
      return x.title && x.title.toLowerCase().indexOf(val) >= 0
    }).map(
      x => <li obj={x}> Was it {x.title}? </li>
    )
  }

  onChange(el_or_str, obj){
    if (!obj) return this.props.onAdded(el_or_str)
    return this.props.onAdded(obj)
  }

  render(){
    return <AutocompleteField
      completions={this.completions.bind(this)}
      onChange={this.onChange.bind(this)}
      placeholder={this.props.placeholder}
    />
  }

}


// return "Add #{obj.name}" if obj.adder
