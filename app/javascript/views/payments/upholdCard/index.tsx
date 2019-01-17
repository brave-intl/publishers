import * as React from 'react'

interface UpholdCardProps {
  name: string;
  isConnected: boolean;
}
interface MyState {
  count: number // like this
}

import locale from '../../../locale/en.js'

export default class UpholdCard extends React.Component<UpholdCardProps, MyState> {
  static defaultProps = { isConnected: true };

  render () {
    return (
      <div>
        <div>Name: {this.props.name}</div>
        <div>isConnected: {this.props.isConnected.toString()}</div>


      </div>
    )
  }
}
