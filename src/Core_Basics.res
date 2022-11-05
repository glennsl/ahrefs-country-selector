module Array = Js.Array2
module String = Js.String2

module Nullable = Js.Nullable
type nullable<'a> = Js.nullable<'a>
let null = Nullable.null

let setTimeout = Js.Global.setTimeout
