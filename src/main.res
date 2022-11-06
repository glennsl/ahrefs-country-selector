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
      <CountrySelect />
    </main>
}

ReactDOM.render(<App />, ReactDOM.querySelector("#app") |> Belt.Option.getExn)
