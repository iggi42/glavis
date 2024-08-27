defmodule Glavis.Keystore.Behaviour do
  @doc """
  insert a new key to the store.
  """
  @callback insert(binary()) :: :ok | :error

  @callback get(binary()) :: binary() | nil

  @callback list() :: list(binary())
end
