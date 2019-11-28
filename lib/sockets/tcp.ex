defmodule MqttBroker.Socket.Tcp do
  @behaviour MqttBroker.Socket

  @impl
  def prepare, do: :ok

  @impl
  def run(port) do
    :gen_tcp.listen(port, [
      :binary,
      {:packet, 0},
      active: false,
      reuseaddr: true
    ])
  end

  @impl
  def accept(listen_socket), do: :gen_tcp.accept(listen_socket)

  @impl
  def recv(socket, size, timeout), do: :gen_tcp.recv(socket, size, timeout)

  @impl
  def send(socket, data), do: :gen_tcp.send(socket, data)

  @impl
  def close(socket), do: :gen_tcp.close(socket)

  @impl
  def controlling_process(client, taskPid), do: :gen_tcp.controlling_process(client, taskPid)
end
