open Core_Basics

type t = Js.Json.t
type validator<'a> = t => 'a

module Validate = {
  type fieldValidators = {required: 'a. validator<'a> => 'a}

  exception ValidationError(string)

  module Error = {
    let expected = (kind, json) => ValidationError(
      `Expected ${kind}, got ${Js.Json.stringify(json)}`,
    )
  }

  let custom = (validate, json) => validate(json)

  let string = json =>
    if Js.typeof(json) == "string" {
      Obj.magic(json)
    } else {
      raise(Error.expected("string", json))
    }

  let array = (validate, json) =>
    if Array.isArray(json) {
      Obj.magic(json)->Array.forEach(json => validate(json)->ignore)
      Obj.magic(json)
    } else {
      raise(Error.expected("array", json))
    }

  let object = f => {
    let required = validate => Obj.magic(validate) // HACK: unsound, to exploit type checking of record to get an exhaustive list of validators for all record fields
    let validators = f({required: required})

    json => {
      if Js.typeof(json) != "object" || Js.Array.isArray(json) || Obj.magic(json) == Js.null {
        raise(Error.expected("object", json))
      }

      Obj.magic(validators)
      ->Js.Obj.keys
      ->Array.forEach(key => {
        let validate = %raw("validators[key]")
        if !(%raw("key in json")) {
          raise(ValidationError(`${key} required`))
        }

        validate(%raw("json[key]"))
      })

      Obj.magic(json)
    }
  }

  let run = (json, validate) =>
    try Ok(validate(json)) catch {
    | ValidationError(err) => Error(err)
    }
}

let validate = Validate.run
