open Core
open Ffi
open Model

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

  let getCountries = (): Promise.t<result<array<country>, string>> => {
    Fetch.get(
      "https://gist.githubusercontent.com/rusty-key/659db3f4566df459bd59c8a53dc9f71f/raw/4127f9550ef063121c564025f6d27dceeb279623/counties.json",
    )
    ->Promise.flatMap(response =>
      if response->Fetch.Response.ok {
        response->Fetch.Response.json->Promise.map(Json.validate(_, Validate.countries))
      } else {
        Error(response->Fetch.Response.statusText)->Promise.resolve
      }
    )
    ->Promise.catch(_ => Error("Network error"))
  }

  @react.component
  let make = () => {
    let (countries, setCountries) = React.useState(() => [])
    let (isOpen, setOpen) = React.useState(() => false)
    let ref = React.useRef(null)

    let toggle = _ => setOpen(isOpen => !isOpen)
    let close = () => setOpen(_ => false)

    React.useEffect1(() => {
      getCountries()->Promise.iter(result =>
        switch result {
        | Ok(countries) => setCountries(_ => countries)
        | Error(err) => Js.log2("Error: ", err)
        }
      )
      None
    }, [])

    React.useEffect1(() => {
      if isOpen {
        let maybeClose = %raw(`function(close, event) {
          if (ref.current && !ref.current.contains(event.target)) {
              close()
          }
        }`)

        let onClick = event => maybeClose(close, event)

        setTimeout(() => Document.addEventListener("click", onClick), 0)->ignore
        Some(() => Document.removeEventListener("click", onClick))
      } else {
        None
      }
    }, [isOpen])

    <div className=css>
      <button onClick=toggle> {"Click me!"->React.string} </button>
      <div ref={ReactDOM.Ref.domRef(ref)} className={`dropdown ${isOpen ? "open" : ""}`}>
        <ul>
          {countries
          ->Array.map(country =>
            <li key=country.value>
              <FlagIcon lang=country.value />
              {country.label->React.string}
            </li>
          )
          ->React.array}
        </ul>
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
