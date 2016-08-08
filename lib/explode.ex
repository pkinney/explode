defmodule Explode do
  @table [{100, :continue, "Continue"},
          {101, :switching_protocols, "Switching Protocols"},
          {102, :processing, "Processing"},
          {200, :ok, "OK"},
          {201, :created, "Created"},
          {202, :accepted, "Accepted"},
          {203, :non_authoritative_information, "Non-Authoritative Information"},
          {204, :no_content, "No Content"},
          {205, :reset_content, "Reset Content"},
          {206, :partial_content, "Partial Content"},
          {207, :multi_status, "Multi-Status"},
          {208, :already_reported, "Already Reported"},
          {226, :instance_manipulation_used, "Instance Manipulation Used"},
          {300, :multiple_choices, "Multiple Choices"},
          {301, :moved_permanently, "Moved Permanently"},
          {302, :found, "Moved Temporarily"},
          {303, :see_other, "See Other"},
          {304, :not_modified, "Not Modified"},
          {305, :use_proxy, "Use Proxy"},
          {306, :reserved, "Reserved"},
          {307, :temporary_redirect, "Temporary Redirect"},
          {308, :permanent_redirect, "Permanent Redirect"},
          {400, :bad_request, "Bad Request"},
          {401, :unauthorized, "Unauthorized"},
          {402, :payment_required, "Payment Required"},
          {403, :forbidden, "Forbidden"},
          {404, :not_found, "Not Found"},
          {405, :method_not_allowed, "Method Not Allowed"},
          {406, :not_acceptable, "Not Acceptable"},
          {407, :proxy_authentication_required, "Proxy Authentication Required"},
          {408, :request_timeout, "Request Time-out"},
          {409, :conflict, "Conflict"},
          {410, :gone, "Gone"},
          {411, :length_required, "Length Required"},
          {412, :precondition_failed, "Precondition Failed"},
          {413, :request_entity_too_large, "Request Entity Too Large"},
          {414, :request_uri_too_long, "Request-URI Too Large"},
          {415, :unsupported_media_type, "Unsupported Media Type"},
          {416, :requested_range_not_satisfiable, "Requested Range Not Satisfiable"},
          {417, :expectation_failed, "Expectation Failed"},
          {418, :im_a_teapot, "I'm a teapot"},
          {421, :misdirected_request, "Misdirected Request"},
          {422, :unprocessable_entity, "Unprocessable Entity"},
          {423, :locked, "Locked"},
          {424, :failed_dependency, "Failed Dependency"},
          {425, :unordered_collection, "Unordered Collection"},
          {426, :upgrade_required, "Upgrade Required"},
          {428, :precondition_required, "Precondition Required"},
          {429, :too_many_requests, "Too Many Requests"},
          {431, :request_header_fields_too_large, "Request Header Fields Too Large"},
          {451, :unavailable_for_legal_reasons, "Unavailable For Legal Reasons"},
          {500, :internal_server_error, "Internal Server Error"},
          {501, :not_implemented, "Not Implemented"},
          {502, :bad_gateway, "Bad Gateway"},
          {503, :service_unavailable, "Service Unavailable"},
          {504, :gateway_timeout, "Gateway Time-out"},
          {505, :http_version_not_supported, "HTTP Version Not Supported"},
          {506, :variant_also_negotiates, "Variant Also Negotiates"},
          {507, :insufficient_storage, "Insufficient Storage"},
          {508, :loop_detected, "Loop Detected"},
          {509, :bandwidth_limit_exceeded, "Bandwidth Limit Exceeded"},
          {510, :not_extended, "Not Extended"},
          {511, :network_authentication_required, "Network Authentication Required" }]

  def with(conn, code, message \\ nil) do
    {status_code, obj} = payload_for(code)
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

  defp payload_for(a) when is_atom(a) do
    case List.keyfind(@table, a, 1) do
      {status_code, _, error} -> {status_code, build_body(status_code, error)}
      _ -> payload_for(500)
    end
  end

  defp payload_for(a) when is_number(a) do
    case List.keyfind(@table, a, 0) do
      {status_code, _, error} -> {status_code, build_body(status_code, error)}
      _ -> payload_for(500)
    end
  end

  defp build_body(status_code, error) do
    %{
      "statusCode" => status_code,
      "error" => error,
      "message" => error
    }
  end

  for {code, atom, _} <- @table do
    def unquote(:"#{atom}")(conn, message \\ nil) do
      Explode.with(conn, unquote(code), message)
    end
  end
end
