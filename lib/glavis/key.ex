defmodule Glavis.Key do
  defstruct [:id, :body, :checksum]

  @armor_start "-----BEGIN PGP PUBLIC KEY BLOCK-----"
  @armor_end   "-----END PGP PUBLIC KEY BLOCK-----"

  @typedoc """
  8 scalars

  "identifies" the a key, but is not unique enough for any kind of garantue
  """
  @type id() :: <<_::unquote(8 * 8)>>
  @type t() :: %__MODULE__{id: id()}

  @doc """
  macro used to patter match scalars  in binaries
  """
  defmacro scalar(n) do
    n * 8
  end

  @spec valid_id?(binary()) :: boolean()
  def valid_id?(<<_::scalar(8)>>), do: true
  def valid_id?(_), do: false

  @doc """
  Decode a scalar to an integer.
  """
  @spec decode_scalar(binary()) :: pos_integer()
  def decode_scalar(scalar) do
    :binary.decode_unsigned(scalar, :big)
  end

  @spec parse(binary(), Keyword.t()) :: t()
  def parse(b, opts) do
    %__MODULE__{
      id: <<"TODO">>,
      body: b,
      checksum: opts[:crc]
    }
  end

  @spec parse_keytext(String.t()) :: [t()]
  def parse_keytext(keytext) do
    # keinen Bock auf Regex, diy state machine ist nie eine schlechte idee
    keytext
    |> String.split("\n")
    |> List.foldl({[], [], [], false}, fn
      @armor_start, {[], [], output, false} -> {[], [], output, true}
      @armor_end, {cache, opts, output, true} ->
        keybody = cache |> List.foldl("", &(&1 <> &2)) |> Base.decode64!()
        {[], [], [ parse(keybody, opts) | output], false}
      <<"="::utf8, crc::binary>>, {cache, opts, output, true}  ->
        crc = Base.decode64!(crc)
        {cache, [{:crc, crc} | opts], output, true}
      line, {cache, opts, output, true}       -> {[line | cache], opts, output, true}
      _line, {_cache, _opts, _output, false} = acc -> acc
    end)
    |> then(fn {_, _, keys, _} -> keys end)
  end

end
