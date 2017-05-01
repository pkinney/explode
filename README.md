# Explode

[![Build Status](https://travis-ci.org/pkinney/explode.svg?branch=master)](https://travis-ci.org/pkinney/explode)
[![Hex.pm](https://img.shields.io/hexpm/v/explode.svg)](https://hex.pm/packages/explode)

An easy utility for responding with standard HTTP/JSON error payloads in Plug- and Phoenix-based applications.

This project is heavily influenced by Hapi's Boom module [https://github.com/hapijs/boom]

## Installation

```elixir
defp deps do
  [{:explode, "~> 1.0.1"}]
end
```

## Usage

Turns

```elixir
conn
|> put_resp_content_type("application/json")
|> send_resp(:unauthorized, "{\"statusCode\":403,\"error\":\"Forbidden\",\"message\":\"You are not authorized to view this resource\"}")
|> halt
```

into

```elixir
conn |> Explode.with(403, "You are not authorized to view this resource")

# or

conn |> Explode.forbidden("You are not authorized to view this resource")
```

### Error Responses

Explode sets the status code of the response and normalizes errors into a single structure:

```json
{
    "statusCode": 403,
    "error": "Not Authorized",
    "message": "You are not authorized to view this resource"
}
```

### JSON API

In order to be compliant with the JSON API spec (http://jsonapi.org/format/#errors), 
if the request headers in the `conn` object passed to Explode includes `Accept` 
of `"application/vnd.api+json"`, then the error response will be formatted to match
the JSON API Error Object spect (http://jsonapi.org/format/#errors).  Additionally,
the `Content-Type` header of the response will also be set to 
`"application/vnd.api+json"`.

```json
{		
    "errors" : [{		
        "status": 403,		
        "title":"Forbidden",		
        "detail":"You are not authorized to view this resource"		
    }]		
}
```

### Ecto Changeset

Explode will also accept an `Ecto.Changeset` struct instead of a message.  This allows a Pheonix application to
directly hand a Changeset to Explode without having to do an traversal of errors.

```elixir
changeset = %Ecto.Changeset{
  action: :insert, 
  types: %{},
  changes: %{first_name: "John", last_name: "Smith", password: "foo"},
  errors: [
    password: {"should be at least %{count} character(s)", [count: 5, validation: :length, min: 5]},
    email: {"can't be blank", [validation: :required]}],
  valid?: false,
  data: %User{}
}

Explode.with(conn, changeset)
```

will result in the following error response:

```json
{
    "statusCode": 400,
    "error": "Bad Request",
    "message": "`email` can't be blank, `password` should be at least 5 character(s)"
}
```