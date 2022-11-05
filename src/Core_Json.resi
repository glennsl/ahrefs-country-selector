type t = Js.Json.t
type validator<'a>

module Validate: {
  type fieldValidators = {required: 'a. validator<'a> => 'a}

  let custom: (t => 'a) => validator<'a>
  let string: validator<string>
  let array: validator<'a> => validator<array<'a>>
  let object: (fieldValidators => 'a) => validator<'a>
}

let validate: (t, validator<'a>) => result<'a, string>
