defmodule MqttBroker do

  use Application

  import Supervisor
  @moduledoc """
  Documentation for MqttBroker.
  """

  @doc """
  Hello world.

  ## Examples

      iex> MqttBroker.hello
      :world

  """
  def start(_type, _args) do
    children = [
      { MqttBroker.Listener, Application.get_all_env(:mqtt_broker) }
    ]
    opts = [strategy: :one_for_one, name: MqttBroker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
