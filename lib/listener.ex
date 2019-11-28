defmodule MqttBroker.Listener do
  require Logger

  @socket MqttBroker.Socket.Ssl

  def child_spec(app_config) do
    %{
      id: MqttBroker.Listener,
      start: {__MODULE__, :start_link, [app_config]}
    }
  end

  def start_link(app_config) do
    pid = spawn_link(__MODULE__, :init, [app_config])
    {:ok, pid}
  end

  def init(app_config) do
    :ok = @socket.prepare()
    {:ok, socket} = @socket.run(app_config[:port])
    Logger.info "MQTTBroker running on Port: #{app_config[:port]}"

    await_connection(socket, app_config)
  end

  def await_connection(socket, app_config) do
    case @socket.accept(socket) do
      {:ok, client} ->
        start_connection_task(client, app_config)
      {:error, {:tls_alert, _}} ->
        Logger.info "TLS certificate error"
      {:error, :timeout} ->
        Logger.info "Timed out"
    end
    await_connection(socket, app_config)
  end

  defp start_connection_task(client, app_config) do
    {:ok, pid} = MqttBroker.Client.start_link(client, app_config)
    :ok = @socket.controlling_process(client, pid)
  end
end
