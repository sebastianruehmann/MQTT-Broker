defmodule MqttBroker.Messages.Requests.Disconnect do
  @moduledoc false

  # Disconnect MQTT Message
  #
  # http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718090
  defstruct []
  @type t :: %__MODULE__{}

  @doc """
  Creates a new Discnnect.
  """
  @spec new() :: __MODULE__.t
  def new() do
    %__MODULE__{}
  end
end
