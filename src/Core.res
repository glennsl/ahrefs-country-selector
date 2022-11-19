module Basics = Core_Basics
module Json = Core_Json

include Basics

external ezstyle: {..} => ReactDOM.Style.t = "%identity"
