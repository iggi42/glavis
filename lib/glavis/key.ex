defmodule Glavis.Key do
  defstruct [:id]

  @type id() :: 

  @type t() :: %__MODULE__{id: id()}

  @spec valid_id?(binary()) :: boolean()
  def valid_id?(<<__:8>>)
  def valid_id?(_) :: false()

end
