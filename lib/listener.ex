defmodule MqttBroker.Listener do
  use Task, restart: :permanent
  require Logger

  alias MqttBroker.Decoder
  @listener MqttBroker.Listener.Ssl
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
    :ok = @listener.prepare()
    {:ok, socket} = @listener.run(port)
    Logger.info "MQTTBroker running on Port: #{port}"

    await_connection(socket)
  end

  def await_connection(socket) do
    case @listener.accept(socket) do
      {:ok, client} ->
        start_connection_task(client)
      {:error, {:tls_alert, _}} ->
        Logger.info "TLS certificate error"
      {:error, :timeout} ->
        Logger.info "Timed out"
    end
    await_connection(socket)
  end

  defp start_connection_task(client) do
    {:ok, pid} = Task.Supervisor.start_child(MqttBroker.TaskSupervisor, fn -> serve(client) end)
    :ok = @listener.controlling_process(client, pid)
  end

  defp serve(socket) do
    socket
    |> read_data
    serve(socket)
  end

  defp read_data(socket) do
    socket_timeout = 5000
    case @listener.recv(socket, 0, socket_timeout) do
      {:ok, data} ->
        Decoder.decode(data)
      {:error, :closed} ->
        :ok = @listener.close(socket)
      {:error, :timeout} ->
        :ok = @listener.close(socket)
      {:error, _} ->
        :ok = @listener.close(socket)
      _ ->
        :ok = @listener.close(socket)
    end
  end
end
