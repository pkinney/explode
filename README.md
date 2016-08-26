# Explode

[![Build Status](https://travis-ci.org/pkinney/explode.svg?branch=master)](https://travis-ci.org/pkinney/explode)
[![Hex.pm](https://img.shields.io/hexpm/v/explode.svg)](https://hex.pm/packages/explode)

An easy utility for responding with standard HTTP/JSON error payloads in Plug- and Phoenix-based applications.

This project is heavily influenced by Hapi's Boom module [https://github.com/hapijs/boom]

## Installation

```elixir
defp deps do
  [{:explode, "~> 0.1.1"}]
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
