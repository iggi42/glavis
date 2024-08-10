defmodule Glavis.Keystore.Dummy do
  @behaviour Glavis.Keystore.Behaviour

  @impl true
  def insert(key) do
    IO.inspect(key, pretty: true)
    :ok
  end

end
