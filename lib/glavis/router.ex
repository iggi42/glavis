defmodule Glavis.Router do
  alias Glavis.Keystore
  use Plug.Router

  require Logger

  plug(Plug.Logger, log: :info)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart]
    #TODO   ,pass: ["text/*"]
  )

  plug(:match)
  plug(:dispatch)

  # v1 route
  get "/pks/lookup/v1/:op/:search" do
    opts = conn.params["options"] || []
    lookup(conn, op, search, opts)
  end

  # legacy route
  get "/pks/lookup" do
    case conn.params do
      %{ "op" => op, "search" => search, "options" => opts} -> lookup(conn, op, search, opts)
      %{ "op" => op, "search" => search} -> lookup(conn, op, search)
      _ -> send_resp(conn, 501, "route not implemented")
    end
  end

  post "/pks/add" do
    with keytext <- conn.params["keytext"],
      :ok <- Glavis.Keystore.insert(keytext) do
      send_resp(conn, 200, "submitted key")
    else
      _ ->  send_resp(conn, 500, "something went wrong :S")
    end
  end

  match _ do
    send_resp(conn, 501, "not implemented")
  end


  defp lookup(conn, op, search, opts \\ [])

  defp lookup(conn, "get", "0x" <> keyid, _opts) do
    with {:ok, id} <- Base.decode16(keyid), 
         keytext when is_binary(keytext) <- Keystore.get(id) do 
      send_resp(conn, 200, keytext)
    else
      nil -> send_resp(conn, 404, "key (0x#{keyid}) not found")
      :error -> send_resp(conn, 400, "na, digga")
    end
  end

  defp lookup(conn, op, search, _opts ) do
    Logger.warn("lookup #{op} with search #{search} failed")
    send_resp(conn, 501, "not implemented")
  end
end
