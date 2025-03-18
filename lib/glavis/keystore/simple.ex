# this is a primitive keystore mostly used for development.
# It stores 

defmodule Glavis.Keystore.Simple do
  @behaviour Glavis.Keystore.Behaviour

  require Logger

  @impl true
  def insert(keytext) do
    results =
      for keyring <- parse_keyrings(keytext) do
        new_el = %{
          keytext: keytext,
          fingerprint: extract_fingerprint(keyring)
        }

        GenServer.call(Simple, {:insert, new_el})
      end

    if Enum.all?(results, &(&1 == :ok)), do: :ok, else: :error
  end

  @impl true
  def get(long_key_id), do: GenServer.call(Simple, {:get, long_key_id})

  @impl true
  def list() do
    GenServer.call(Simple, :list) |> Enum.map(&("0x" <> Base.encode16(&1) <> "\n"))
  end

  def extract_fingerprint(keyring) do
    keyring
    |> Enum.find(&match?(%OpenPGP.PublicKeyPacket{}, &1))
    |> then(& &1.fingerprint)
  end

  def parse_keyrings(keytext) do
    for %OpenPGP.Radix64.Entry{name: "PGP PUBLIC KEY BLOCK", data: data} <-
          OpenPGP.Radix64.decode(keytext) do
      data |> OpenPGP.list_packets() |> OpenPGP.cast_packets()
    end
  end

  defmodule Server do
    use GenServer

    alias Glavis.Keystore.Simple, as: S

    # maybe make a configure able option?
    # in secounds 
    @save_interval 60

    def start_link(init_arg, opts \\ [name: Simple]),
      do: GenServer.start_link(__MODULE__, init_arg, opts)

    @impl true
    def init(_) do
      start_reminder()
      {:ok, [], {:continue, :load}}
    end

    @impl true
    def handle_continue(:load, state) do
      unless state == [], do: Logger.warning("loading from files from non-empty state")

      cond do
        not File.dir?(state_dir()) ->
          {:noreply, []}

        not File.exists?(keyfile()) ->
          {:noreply, []}

        true ->
          keytext = File.read!(keyfile())

          new_state =
            for keyring <- S.parse_keyrings(keytext) do
              %{
                keytext: keytext,
                fingerprint: S.extract_fingerprint(keyring)
              }
            end

          {:noreply, new_state}
      end
    end

    @impl true
    def handle_cast(:save, state) do
      save_state(state)
      start_reminder()
      {:noreply, state}
    end

    @impl true
    def handle_call({:insert, el}, _from, state) do
      {:reply, :ok, [el | state]}
    end

    def handle_call(:list, _from, state) do
      ids = Enum.map(state, & &1.fingerprint)
      {:reply, ids, state}
    end

    def handle_call({:get, long_key_id}, _from, state) do
      case Enum.find(state, &(long_key_id == &1.fingerprint)) do
        %{keytext: kt} -> {:reply, kt, state}
        nil -> {:reply, nil, state}
      end
    end

    defp save_state(state) do
      kf = keyfile()
      keytext = Enum.map(state, & &1.keytext)
      File.write(kf, keytext)
    end

    defp state_dir() do
      Application.get_env(:glavis, :state) || Path.join(System.tmp_dir!(), "glavis")
    end

    defp keyfile() do
      state_dir() |> Path.join("./keys.txt") |> Path.expand()
    end

    defp start_reminder() do
      Task.start_link(fn ->
        Process.sleep(1_000 * @save_interval)
        GenServer.cast(Simple, :save)
      end)
    end
  end
end
