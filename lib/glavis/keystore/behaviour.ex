defmodule Glavis.Keystore.Behaviour do
  @doc """
  insert a new key to the store.
  """
  @callback insert(Glavis.Key.t()) :: :ok | :error
end
