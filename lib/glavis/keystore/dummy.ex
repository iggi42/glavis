defmodule Glavis.Keystore.Dummy do
  @behaviour Glavis.Keystore.Behaviour

  @impl true
  def insert(keytext) do
     results = for keyring <- parse_keyrings(keytext) do
      new_el = %{
        keytext: keytext,
        fingerprint: extract_fingerprint(keyring)
      }

      GenServer.call(Dummy, {:insert, new_el})
    end
    if Enum.all?(results, &(&1 == :ok)) do
      :ok
    else
      :error
    end
  end

  @impl true
  def get(long_key_id), do: GenServer.call(Dummy, {:get, long_key_id})

  defp extract_fingerprint(keyring) do
    keyring
    |> Enum.find(&match?(%OpenPGP.PublicKeyPacket{}, &1))
    |> then(&(&1.fingerprint))
  end

  defp parse_keyrings(keytext) do
    for %OpenPGP.Radix64.Entry{name: "PGP PUBLIC KEY BLOCK", data: data}  <- OpenPGP.Radix64.decode(keytext) do
      data |> OpenPGP.list_packets() |> OpenPGP.cast_packets()
    end
  end

  defmodule Server do
    use GenServer

    def start_link(init_arg, opts \\ [name: Dummy]), do: GenServer.start_link(__MODULE__, init_arg, opts)

    @impl true
    def init(_), do: {:ok, []}

    @impl true
    def handle_call({:insert, el}, _from, state) do
      IO.inspect(el, pretty: true)
      {:reply, :ok, [ el | state]}
    end

    def handle_call({:get, long_key_id}, _from, state) do
      case  Enum.find(state, &(long_key_id == &1.fingerprint)) do
        %{keytext: kt} -> {:reply, kt, state}
        nil -> {:reply, nil, state}
      end
    end
  end


end
