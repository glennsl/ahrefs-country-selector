module Emotion = {
  @module("@emotion/css") external css: string => string = "css"
}

module Document = {
  // NOTE: 'event is unsoundly typed
  @val external addEventListener: (string, 'event => unit) => unit = "document.addEventListener"
  // NOTE: 'event is unsoundly typed
  @val
  external removeEventListener: (string, 'event => unit) => unit = "document.removeEventListener"
}

module Element = {
  @get external clientHeight: Dom.element => int = "clientHeight"
  @get external scrollTop: Dom.element => int = "scrollTop"
  @get external scrollHeight: Dom.element => int = "scrollHeight"

  @send external focus: Dom.element => unit = "focus"

  // NOTE: 'event is unsoundly typed
  @send
  external addEventListener: (Dom.element, string, 'event => unit) => unit = "addEventListener"
  // NOTE: 'event is unsoundly typed
  @send
  external removeEventListener: (Dom.element, string, 'event => unit) => unit =
    "removeEventListener"
}

module Promise = {
  type t<+'a>
  type error

  @val external resolve: 'a => t<'a> = "Promise.resolve"

  // HACK: not sound, but for the sake of this let's just pretend it is and use one of the proper third-party bindings in prod
  @send external map: (t<'a>, 'a => 'b) => t<'b> = "then"
  @send external flatMap: (t<'a>, 'a => t<'b>) => t<'b> = "then"
  @send external iter: (t<'a>, 'a => unit) => unit = "then"
  @send external catch: (t<'a>, error => 'a) => t<'a> = "catch"
}

module Fetch = {
  module Response = {
    type t

    @get external ok: t => bool = "ok"
    @get external statusText: t => string = "statusText"

    @send external json: t => Promise.t<Js.Json.t> = "json"
  }

  @val external get: string => Promise.t<Response.t> = "fetch"
}
