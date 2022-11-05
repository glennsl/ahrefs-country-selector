open Core

type country = {
  label: string,
  value: string,
}

module Validate = {
  include Json.Validate

  let country = object(field => {
    label: field.required(string),
    value: field.required(string),
  })

  let countries = array(country)
}
