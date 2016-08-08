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
