defmodule Glavis.Router do
  use Plug.Router

  plug(Plug.Logger, log: :debug)

  plug(:match)
  plug(:dispatch)

  # v1 route
  get "/pks/lookup/v1/get/:search" do
  end

  # legacy route
  get "/pks/lookup" do
    send_resp(conn, 501, "legacy request route not implemented")
  end

  get "/pks/lookup/v1/:op/:search" do
    send_resp(conn, 501, "operation #{op} not implemented")
  end

  match _ do
    send_resp(conn, 501, "not implemented")
  end
end
