open Core
open Ffi
open Model

let css = Emotion.css(`
  display: flex;
  flex-direction: column;
  gap: 1ex;

  position: relative;

  font-family: 'Roboto';
  font-size: 14px;
  line-height: 18px;
  color: #333;

  & > button {
    display: flex;
    align-items: center;
    gap: 1ex;

    padding: .5ex 1ex;

    background: #FFF;
    border: 1px solid rgba(0, 0, 0, 0.2);
    border-radius: 3px;
  }

  & > .dropdown {
    position: absolute;
    top: calc(100% + .5ex);

    display: flex;
    flex-direction: column;

    max-height: 15em;
    width: 20em;

    background: #FFF;
    border: 1px solid rgba(0, 0, 0, 0.08);
    box-shadow: 0px 1px 3px rgba(0, 0, 0, 0.1);
    border-radius: 2px;

    & > .search {
      display: flex;
      gap: 1ex;
      padding: .75ex 1ex;

      box-shadow: inset 0px -1px 0px rgba(0, 0, 0, 0.08);

      & > img {
        width: 1em;
        padding: 0 2px;
      }

      & > input {
        flex: 1;
        border: none;

        font-family: 'Roboto';
        font-size: 14px;
        line-height: 18px;
        color: #333;

        &::placeholder {
          color: #ADADAD;
        }

        &:focus-visible {
          outline: none;
        }
      }
    }

    & > .list {
      margin: 0;
      padding: 0;
      overflow: auto;

      & > .list-item {
        display: flex;
        gap: 1ex;

        white-space: nowrap;
        padding: .75ex 1ex;
        cursor: pointer;

        & > .label {
          text-overflow: ellipsis;
          overflow: hidden;
        }

        &.focused {
          background: #eee;
        }

        &:hover {
          background: whitesmoke;
        }
      }
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
let make = (~className="", ~country as selectedValue, ~onChange) => {
  let (countries, setCountries) = React.useState(() => [])
  let (isOpen, setOpen) = React.useState(() => false)
  let (filter, setFilter) = React.useState(() => "")
  let (focus, setFocus) = React.useState(() => 0)
  let dropdownRef = React.useRef(null)

  let selectedCountry =
    selectedValue->Option.flatMap(value => countries->Array.find(country => country.value == value))

  let filteredCountries = if filter == "" {
    countries
  } else {
    countries->Array.filter(country => country.label->String.toLowerCase->String.includes(filter))
  }

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
      let onClick = event =>
        dropdownRef.current->Nullable.iter((. el) =>
          if !Element.contains(el, event["target"]) {
            close()
          }
        )

      setTimeout(() => Document.addEventListener("click", onClick), 0)->ignore
      Some(() => Document.removeEventListener("click", onClick))
    } else {
      None
    }
  }, [isOpen])

  let onChange = country => {
    onChange(country)
    close()
  }

  let onKeyDown = event => {
    switch event->ReactEvent.Keyboard.key {
    | "Escape" => close() // TODO: Also focus button?
    | "ArrowUp" => setFocus(i => i - 1)
    | "ArrowDown" => setFocus(i => i + 1)
    | "Enter" => filteredCountries->Belt.Array.get(focus)->Option.forEach(onChange)
    | _ => ()
    }
  }

  <div onKeyDown className={`${css} ${className}`}>
    <button onClick=toggle>
      {selectedCountry
      ->Option.mapWithDefault("Select country", country => country.label)
      ->React.string}
      {Icon.arrow}
    </button>
    {if isOpen {
      <div ref={ReactDOM.Ref.domRef(dropdownRef)} className="dropdown">
        <div className="search">
          {Icon.search}
          <input
            ref={ReactEx.Ref.onMount(Element.focus)}
            type_="text"
            placeholder="Search"
            onInput={event => setFilter(_ => (event->ReactEvent.Form.target)["value"])}
            value=filter
          />
        </div>
        <VirtualizedList className="list" items=filteredCountries>
          ...{(country, i) =>
            <div
              className={`list-item ${focus == i ? "focused" : ""}`}
              key=country.value
              onClick={_ => onChange(country)}>
              <FlagIcon lang=country.value />
              <span className="label"> {country.label->React.string} </span>
            </div>}
        </VirtualizedList>
      </div>
    } else {
      React.null
    }}
  </div>
}
