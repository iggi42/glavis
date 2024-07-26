defmodule GlavisTest do
  use ExUnit.Case
  doctest Glavis

  test "greets the world" do
    assert Glavis.hello() == :world
  end
end
