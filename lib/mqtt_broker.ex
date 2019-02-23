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
      { Task.Supervisor, name: MqttBroker.TaskSupervisor },
      { MqttBroker.Listener, Application.get_env(:mqtt_broker, :port) }
    ]
    opts = [strategy: :one_for_one, name: MqttBroker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
