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
    with keytext <- conn.params["keytext"],
      [%OpenPGP.Radix64.Entry{name: "PGP PUBLIC KEY BLOCK", data: data}] <- OpenPGP.Radix64.decode(keytext) do

      r = data
      |> OpenPGP.list_packets()
      |> OpenPGP.cast_packets()

      send_resp(conn, 200, "submitting keys is WIP\n")
    else
      _ ->  send_resp(conn, 500, "something went wring :S\n")
    end
  end

  match _ do
    send_resp(conn, 501, "not implemented")
  end
end
