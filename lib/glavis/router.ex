defmodule Glavis.Router do
  use Plug.Router

  require Logger

  plug(Plug.Logger, log: :debug)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart],
    #TODO   pass: ["text/*"]
  )

  plug(:match)
  plug(:dispatch)

  # v1 route
  get "/pks/lookup/v1/get/:search" do
    send_resp(conn, 501, "get is in WIP")
  end

  # legacy route
  get "/pks/lookup" do
    send_resp(conn, 501, "legacy request route not implemented")
  end

  get "/pks/lookup/v1/:op/:search" do
    send_resp(conn, 501, "operation #{op} not implemented")
  end

  post "/pks/add" do
    with keytext <- conn.params["keytext"] do
      keytext
      |> Glavis.Key.parse_keytext()
      |> Enum.each(&Glavis.Keystore.insert/1)
    end

    send_resp(conn, 200, "submitting keys is WIP\n")
  end

  match _ do
    send_resp(conn, 501, "not implemented")
  end
end
