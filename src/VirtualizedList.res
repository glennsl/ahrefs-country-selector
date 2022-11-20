open Core
open Ffi

@react.component
let make = (~className="", ~items, ~children as render) => {
  let (maybeContainerHeight, setContainerHeight) = React.useState(() => None)
  let (scrollTop, setScrollTop) = React.useState(() => 0)
  let (itemHeight, setItemHeight) = React.useState(() => 10)
  let containerRef = React.useRef(null)

  let numberToRender = switch maybeContainerHeight {
  | Some(height) => height / itemHeight + 2
  | None => 10
  }

  React.useEffect1(() =>
    containerRef.current
    ->Nullable.toOption
    ->Option.map(el => {
      setContainerHeight(_ => Some(el->Element.clientHeight))
      setItemHeight(
        currentItemHeight => {
          let numberNotRendered = items->Array.length - numberToRender
          let renderedHeight = el->Element.scrollHeight - numberNotRendered * currentItemHeight
          renderedHeight / numberToRender
        },
      )

      let onScroll = () => setScrollTop(_ => el->Element.scrollTop)
      el->Element.addEventListener("scroll", onScroll)

      () => el->Element.removeEventListener("scroll", onScroll)
    })
  , [containerRef])

  let startIndex = Js.Math.max_int(scrollTop / itemHeight - 1, 0)
  let indicesToRender = Belt.Array.init(numberToRender, i => i + startIndex)
  let remaining = items->Array.length - startIndex - numberToRender

  <div className ref={ReactDOM.Ref.domRef(containerRef)}>
    <div style={ReactEx.style({height: startIndex * itemHeight})} />
    {indicesToRender
    ->Array.map(i =>
      items->Belt.Array.get(i)->Option.map(render(_, i))->Option.getWithDefault(React.null)
    )
    ->React.array}
    <div style={ReactEx.style({height: remaining * itemHeight})} />
  </div>
}
