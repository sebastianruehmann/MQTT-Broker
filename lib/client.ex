defmodule MqttBroker.Client do
  defstruct socket: nil,
          client_id: nil,
          keep_alive_server_ms: nil,
          auth_info: nil,
          app_config: nil,
          persistent_session: false

  @socket MqttBroker.Socket.Ssl
  use GenServer

  alias MqttBroker.Decoder
  alias MqttBroker.Client
  alias MqttBroker.Messages.Requests.{Connect, Disconnect}
  require Logger

  def start_link(client, app_config, _opts \\ []) do
    state = %Client{socket: client, app_config: app_config}
    GenServer.start_link(__MODULE__, state)
  end

  def init(client) do
    GenServer.cast(self, :listen)
    {:ok, client}
  end

  def handle_cast(:listen, %Client{socket: socket, client_id: client_id} = state) do
    socket_timeout = 5000
    { :ok, data } = @socket.recv(socket, 0, socket_timeout)
    data
    |> Decoder.decode
    |> process_msg(state)
  end

  def handle_cast({:authenticate, %Connect{client_id: client_id} = msg}, %Client{socket: socket} = state) do
      case MqttBroker.Authentication.connect(msg, state) do
        {res_msg, %Client{auth_info: auth_info} = client} ->
            # Socket.send(socket, res_msg)
            GenServer.cast(self, :verified_loop)
            {:noreply, client}
        {:error, emsg} ->
            # Socket.send(socket, emsg)
            {:stop, :normal, state}
      end
  end

  defp authenticate(%Connect{} = message, state) do
    GenServer.cast(self, {:authenticate, message})
    {:noreply, state}
  end

  defp authenticate(message, state) do
    Logger.warn "#{inspect message} is not authorized and send a wrong message."
    {:stop, :normal, state}
  end

  defp process_msg(msg, %Client{client_id: client_id, auth_info: auth_info} = state) do
    case msg do
      %Connect{} ->
        authenticate(msg, state)
      %Disconnect{} ->
        {:stop, :normal, state}
      _other ->
        # case Skyline.Handler.handle_msg(msg, state) do
        #   {:close_connection, reason} ->
        #     {:stop, :normal, state}
        #   %Client{} = new_state ->
        #     GenServer.cast(self, :listen)
        #     {:noreply, new_state}
        # end
    end
  end
end
