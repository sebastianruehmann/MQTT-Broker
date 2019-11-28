defmodule MqttBroker.Socket.Ssl do
  @behaviour MqttBroker.Socket

  @impl
  def prepare, do: :ssl.start()

  @impl
  def run(port) do
    :ssl.listen(port, [
      :binary,
      {:certfile, "cert.pem"},
      {:keyfile, "key.pem"},
      {:packet, 0},
      reuseaddr: true,
      active: false,
    ])
  end

  @impl
  def accept(listen_socket) do
    case :ssl.transport_accept(listen_socket) do
      {:ok, transport_socket} ->
        :ssl.handshake(transport_socket)
      default -> default
    end
  end

  @impl
  def recv(socket, size, timeout), do: :ssl.recv(socket, size, timeout)

  @impl
  def send(socket, data), do: :ssl.send(socket, data)

  @impl
  def close(socket), do: :ssl.close(socket)

  @impl
  def controlling_process(client, taskPid), do: :ssl.controlling_process(client, taskPid)
end
