open Ffi

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
      <CountrySelect country=Some("us") onChange={country => Js.log(country)} />
    </main>
}

ReactDOM.render(<App />, ReactDOM.querySelector("#app") |> Belt.Option.getExn)
