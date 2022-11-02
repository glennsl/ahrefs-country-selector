module Emotion = {
  @module("@emotion/css") external css: string => string = "css"
}

module Document = {
  @val external addEventListener: (string, 'event => unit) => unit = "document.addEventListener"
  @val
  external removeEventListener: (string, 'event => unit) => unit = "document.removeEventListener"
}

module CountrySelect = {
  let css = Emotion.css(`
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;

    & > .dropdown {

      &:not(.open) {
        display: none;
      }
    }
  `)

  @react.component
  let make = () => {
    let (isOpen, setOpen) = React.useState(() => false)
    let ref = React.useRef(Js.Nullable.null)

    let toggle = _ => setOpen(isOpen => !isOpen)
    let close = () => setOpen(_ => false)

    React.useEffect1(() => {
      if isOpen {
        let maybeClose = %raw(`function(close, event) {
          if (ref.current && !ref.current.contains(event.target)) {
              close()
          }
        }`)

        let onClick = event => maybeClose(close, event)

        Js.Global.setTimeout(() => Document.addEventListener("click", onClick), 0)->ignore
        Some(() => Document.removeEventListener("click", onClick))
      } else {
        None
      }
    }, [isOpen])

    <div className=css>
      <button onClick=toggle> {"Click me!"->React.string} </button>
      <div ref={ReactDOM.Ref.domRef(ref)} className={`dropdown ${isOpen ? "open" : ""}`}>
        {"Hello"->React.string}
      </div>
    </div>
  }
}

module App = {
  let css = Emotion.css(`
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
  `)

  @react.component
  let make = () =>
    <main className=css>
      <CountrySelect />
    </main>
}

ReactDOM.render(<App />, ReactDOM.querySelector("#app") |> Belt.Option.getExn)
