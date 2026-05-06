defmodule GlavisRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  doctest Glavis.Router

  @opts Glavis.Router.init([])

  describe "Lookups via v1 Route"  do
    test "KidGet key (expect success)" do
      "./test/ig_test_armor.key"
      |> File.read!()
      |> Glavis.Keystore.insert()

      id = "BF04ADD7D008B70476FF09ACF27BBC7F9FC2F2A9"
      conn = conn(:get, "/pks/lookup/v1/kidget/0x#{id}") |> Glavis.Router.call(@opts)

      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 200
    end

    test "KidGet key 0xDEADBEEFDECAFSAD (expect not found)" do
      conn = conn(:get, "/pks/lookup/v1/kidget/0xDEADBEEFDECAFSAD") |> Glavis.Router.call(@opts)

      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 400
    end

    test "get key 0xDEADBEEFDECAFBAD (expect success)" do
      "./test/ig_test_armor.key"
      |> File.read!()
      |> Glavis.Keystore.insert()

      id = "BF04ADD7D008B70476FF09ACF27BBC7F9FC2F2A9"
      conn = conn(:get, "/pks/lookup/v1/get/0x#{id}") |> Glavis.Router.call(@opts)

      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 200
    end

    test "get key 0xDEADBEEFDECAFSAD (expect not found)" do
      conn = conn(:get, "/pks/lookup/v1/get/0xDEADBEEFDECAFSAD") |> Glavis.Router.call(@opts)

      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 400
    end
  end
end
