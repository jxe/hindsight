import React from 'react'
import AutocompleteField from './controls/AutocompleteField.jsx'

export default class CXReasonEntryField extends React.Component {

  emptyCompletions(){
    var { cx, excludeReasons, resource } = this.props
    var commonReasons = []
    if (resource) commonReasons = cx.commonReasons(resource)
    return commonReasons.filter( x => {
      return excludeReasons.indexOf(x.id) == -1
    }).map(
      x => <li className="completion table-view-cell" obj={x}>
        <b>{x.title}</b>
        <p>
          A common {x.type} for this site
        </p>
      </li>
    )
  }

  aWhat(rel){
    return {
      "is": "",
      "syn": "is a synonym of this",
      "yield": "is made possible by this",
      "hypo": "is a type of this",
    }[rel]
  }

  completions(val){
    if (!val) return this.emptyCompletions();
    var { cx, excludeReasons } = this.props
    var completions = cx.completions(val)
    return completions.filter( x=> {
      return excludeReasons.indexOf(x.id) == -1
    }).map(
      x => <li className="completion table-view-cell" obj={x}>
        <b>{x[3]}</b>
        <p>
          <b>{x[2]}</b> {this.aWhat(x[1])}
        </p>
      </li>
    )
  }

  onChange(el_or_str, obj){
    console.log('onChange', el_or_str, obj)
    if (!obj) return this.props.onAdded(el_or_str)
    return this.props.onAdded({ id: (obj.id || obj[0]) })
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
