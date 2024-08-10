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

  defdelegate insert(key),
    to: Application.compile_env(:glavis, [Glavis.Keystore, :impl], Glavis.Keystore.Dummy)

end
