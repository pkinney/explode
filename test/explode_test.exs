defmodule ExplodeTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "send a default message for an error" do
    conn =
      conn(:get, "/api/v1/things")
      |> Explode.with(:unauthorized)

    assert conn.state == :sent
    assert conn.status == 401
    assert Poison.decode!(conn.resp_body) == %{
      "error" => "Unauthorized",
      "message" => "Unauthorized",
      "statusCode" => 401}
  end

  test "send a default message for an error in json api format" do
    conn =
      conn(:get, "/api/v1/things")
      |> put_req_header("accept", "application/vnd.api+json")
      |> Explode.with(:unauthorized)

    assert conn.state == :sent
    assert conn.status == 401
    assert Enum.member?(conn.resp_headers, {"content-type", "application/vnd.api+json; charset=utf-8"})
    assert Poison.decode!(conn.resp_body) == %{
      "errors" => [%{
        "status" => 401,
        "title" => "Unauthorized",
        "detail" => "Unauthorized"
      }]
    }
  end

  test "send a add a custom message for an error" do
    conn =
      conn(:get, "/api/v1/things")
      |> Explode.with(:unauthorized, "Username and password invalid")

    assert conn.state == :sent
    assert conn.status == 401
    assert Poison.decode!(conn.resp_body) == %{
      "error" => "Unauthorized",
      "message" => "Username and password invalid",
      "statusCode" => 401}
  end
  
  defmodule User do
    defstruct [:first_name, :last_name, :email, :password]
  end
  
  test "use errors from an Ecto.Changeset" do
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

    conn = 
      conn(:get, "/api/v1/things")
      |> Explode.with(changeset)

    assert conn.state == :sent
    assert conn.status == 400
    assert Poison.decode!(conn.resp_body) == %{
      "error" => "Bad Request",
      "message" => "`email` can't be blank, `password` should be at least 5 character(s)",
      "statusCode" => 400}
  end

  test "common-name functions for each status code without a message" do
    conn =
      conn(:get, "/api/v1/things")
      |> Explode.unauthorized

    assert conn.state == :sent
    assert conn.status == 401
    assert Poison.decode!(conn.resp_body) == %{
      "error" => "Unauthorized",
      "message" => "Unauthorized",
      "statusCode" => 401}
  end

  test "common-name functions for each status code with message" do
    conn =
      conn(:get, "/api/v1/things")
      |> Explode.unauthorized("Username and password invalid")

    assert conn.state == :sent
    assert conn.status == 401
    assert Poison.decode!(conn.resp_body) == %{
      "error" => "Unauthorized",
      "message" => "Username and password invalid",
      "statusCode" => 401}
  end

  test "common-name functions for JSON API formatted errors" do
    conn =
      conn(:get, "/api/v1/things")
      |> put_req_header("accept", "application/vnd.api+json")
      |> Explode.unauthorized("Username and password invalid")

    assert conn.state == :sent
    assert conn.status == 401
    assert Poison.decode!(conn.resp_body) == %{
      "errors" => [%{
        "status" => 401,
        "title" => "Unauthorized",
        "detail" => "Username and password invalid"
      }]
    }
  end

  test "returns 500 for an unknown error" do
    conn =
      conn(:get, "/api/v1/things")
      |> Explode.with(:not_a_real_error, "foo")

    assert conn.state == :sent
    assert conn.status == 500
    assert Poison.decode!(conn.resp_body) == %{
      "error" => "Internal Server Error",
      "message" => "An internal server error occurred",
      "statusCode" => 500}
  end
end
