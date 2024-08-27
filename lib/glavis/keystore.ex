defmodule Glavis.Keystore do
  @moduledoc """
  This is the frontend for the key store.

  Specify which implementation to use like this:
  ```elixir
  config :glavis, Glavis.Keystore,
     impl: MyImplModule
  ```
  `MyImplModule` needs to implement `Glavis.Keystore.Behaviour` for that.
  """

  defdelegate insert(armored_key),
    to: Application.compile_env(:glavis, [Glavis.Keystore, :impl], Glavis.Keystore.Small)

  defdelegate get(key_id),
    to: Application.compile_env(:glavis, [Glavis.Keystore, :impl], Glavis.Keystore.Small)

  defdelegate list(),
    to: Application.compile_env(:glavis, [Glavis.Keystore, :impl], Glavis.Keystore.Small)
end
