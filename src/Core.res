module Basics = Core_Basics
module Json = Core_Json

include Basics

module ReactEx = {
  module Ref = {
    let onMount = f =>
      ReactDOM.Ref.callbackDomRef(maybeEl => maybeEl->Nullable.iter((. el) => el->f))
  }

  type style = {height?: int}
  external style: style => ReactDOM.Style.t = "%identity"
}
