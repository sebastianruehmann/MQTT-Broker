defmodule MqttBroker.Listener.Tcp do
  def prepare, do: :ok

  def run(port) do
    :gen_tcp.listen(port, [
      :binary,
      {:packet, 0},
      active: false,
      reuseaddr: true
    ])
  end

  def accept(listen_socket), do: :gen_tcp.accept(listen_socket)

  def recv(socket, size, timeout), do: :gen_tcp.recv(socket, size, timeout)

  def send(socket, data), do: :gen_tcp.send(socket, data)

  def close(socket), do: :gen_tcp.close(socket)

  def controlling_process(client, taskPid), do: :gen_tcp.controlling_process(client, taskPid)
end
