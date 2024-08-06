defmodule GlavisRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  doctest Glavis.Router

  @opts Glavis.Router.init([])

  describe "Lookups via v1 Route" do
    test "Get key 0xDEADBEEFDECAFBAD (expect success)" do
      conn = conn(:get, "/pks/lookup/v1/kidget/DEADBEEFDECAFBAD") |> Glavis.Router.call(@opts)

      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 200
    end

    test "Get key 0xDEADBEEFDECAFSAD (expect not found)" do
      conn = conn(:get, "/pks/lookup/v1/kidget/DEADBEEFDECAFSAD") |> Glavis.Router.call(@opts)

      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 404
    end
  end
end
