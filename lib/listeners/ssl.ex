defmodule MqttBroker.Listener.Ssl do
  def prepare, do: :ssl.start()

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

  def accept(listen_socket) do
    case :ssl.transport_accept(listen_socket) do
      {:ok, transport_socket} ->
        :ssl.handshake(transport_socket)
      default -> default
    end
  end

  def handshake(transport_socket), do: :ssl.handshake(transport_socket)

  def recv(socket, size, timeout), do: :ssl.recv(socket, size, timeout)

  def send(socket, data), do: :ssl.send(socket, data)

  def close(socket), do: :ssl.close(socket)

  def controlling_process(client, taskPid), do: :ssl.controlling_process(client, taskPid)
end
