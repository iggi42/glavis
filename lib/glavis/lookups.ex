defmodule Glavis.Lookups do
  alias Glavis.Key

  def kidget(backend, keyid)

  defmodule Backend do
    @callback get(Key.id()) :: Key.t()
  end
end
