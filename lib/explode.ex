defmodule Explode do
  def with(conn, code, message \\ nil) do
  {status_code, obj} = Explode.Code.payload_for(code)
  case {status_code, message} do
    {500, _} -> do_reply(conn, 500, Map.put(obj, "message", "An internal server error occurred"))
    {_, nil} -> do_reply(conn, status_code, obj)
    _ -> do_reply(conn, status_code, Map.put(obj, "message", message))
  end
end

defp do_reply(conn, code, payload) do
  conn
  |> Plug.Conn.put_resp_content_type("application/json")
  |> Plug.Conn.send_resp(code, Poison.encode!(payload))
  |> Plug.Conn.halt
end
end
