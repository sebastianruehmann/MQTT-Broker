defmodule MqttBroker.Listener do
  use Task, restart: :permanent
  require Logger

  alias MqttBroker.Decoder
  @moduledoc """
  Documentation for MqttBroker.
  """

  @doc """
  Hello world.

  ## Examples

      iex> MqttBroker.hello
      :world

  """
  def start_link(port) do
    pid = spawn_link(__MODULE__, :init, [port])
    {:ok, pid}
  end

  def init(port) do
    # TODO: Allow TLS encryption
    {:ok, pid} = :gen_tcp.listen(port, [
      :binary,
      {:packet, 0},
      active: false,
      reuseaddr: true
    ])
    Logger.info "Accepting connections on port #{port}"
    await_connection(pid)
  end

  defp await_connection(pid) do
    case :gen_tcp.accept(pid) do
      {:ok, client} ->
        {:ok, taskPid} = Task.Supervisor.start_child(MqttBroker.TaskSupervisor, fn -> read_data(client) end)
        :ok = :gen_tcp.controlling_process(client, taskPid)
        await_connection(pid)
      {:error, :timeout} ->
        Logger.info "Timed out"
    end
  end

  defp read_data(client) do
    socket_timeout = 5000
    case :gen_tcp.recv(client, 0, socket_timeout) do
      {:ok, data} ->
        Decoder.decode(data)
      {:error, :closed} ->
        :ok = :gen_tcp.close(client)
      {:error, :timeout} ->
        :ok = :gen_tcp.close(client)
      {:error, _} ->
        :ok = :gen_tcp.close(client)
      _ ->
        :ok = :gen_tcp.close(client)
    end
  end
end
