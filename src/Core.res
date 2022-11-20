module Basics = Core_Basics
module Json = Core_Json

include Basics

external ezstyle: {..} => ReactDOM.Style.t = "%identity"

module ReactEx = {
  module Ref = {
    let onMount = f =>
      ReactDOM.Ref.callbackDomRef(maybeEl => maybeEl->Nullable.iter((. el) => el->f))
  }
}
