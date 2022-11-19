open Core
open Ffi

@react.component
let make = (~className="", ~itemHeight, ~items, ~children as render) => {
  let (maybeContainerHeight, setContainerHeight) = React.useState(() => None)
  let (scrollTop, setScrollTop) = React.useState(() => 0)
  let containerRef = React.useRef(null)

  React.useEffect1(() =>
    containerRef.current
    ->Nullable.toOption
    ->Option.map(el => {
      setContainerHeight(_ => Some(el->Element.clientHeight))

      let onScroll = () => setScrollTop(_ => el->Element.scrollTop)
      el->Element.addEventListener("scroll", onScroll)

      () => el->Element.removeEventListener("scroll", onScroll)
    })
  , [containerRef])

  let numberToRender = switch maybeContainerHeight {
  | Some(height) => height / itemHeight + 2
  | None => 10
  }
  let startIndex = Js.Math.max_int(scrollTop / itemHeight - 1, 0)
  let indicesToRender = Belt.Array.init(numberToRender, i => i + startIndex)
  let remaining = items->Array.length - startIndex - numberToRender

  <div className ref={ReactDOM.Ref.domRef(containerRef)}>
    <div style={ezstyle({"height": startIndex * itemHeight})} />
    {indicesToRender
    ->Array.map(i => {
      switch items->Belt.Array.get(i) {
      | Some(item) => render(item)
      | None => React.null
      }
    })
    ->React.array}
    <div style={ezstyle({"height": remaining * itemHeight})} />
  </div>
}
