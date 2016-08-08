defmodule ExplodeTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "send a default message for an error" do
    # Create a test connection
    conn = conn(:get, "/hello")

    # Invoke the plug
    conn = Explode.with(conn, :unauthorized)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 401
    assert Poison.decode!(conn.resp_body) == %{
      "error" => "Unauthorized",
      "message" => "Unauthorized",
      "statusCode" => 401}
  end

  test "send a add a custom message for an error" do
    # Create a test connection
    conn = conn(:get, "/hello")

    # Invoke the plug
    conn = Explode.with(conn, :unauthorized, "Username and password invalid")

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 401
    assert Poison.decode!(conn.resp_body) == %{
      "error" => "Unauthorized",
      "message" => "Username and password invalid",
      "statusCode" => 401}
  end

  test "returns 500 for an unknown error" do
    # Create a test connection
    conn = conn(:get, "/hello")

    # Invoke the plug
    conn = Explode.with(conn, :not_a_real_error, "foo")

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 500
    assert Poison.decode!(conn.resp_body) == %{
      "error" => "Internal Server Error",
      "message" => "An internal server error occurred",
      "statusCode" => 500}
  end
end
