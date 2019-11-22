defmodule MqttBrokerTest do
  use ExUnit.Case


  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 1883, opts)
    %{socket: socket}
  end

  test "tcp listener", %{socket: socket} do
    assert send_msg(socket, "") == {:error, :timeout}
    assert send_msg(socket, "WRONG_COMMAND") == {:error, :closed}
  end

  defp send_msg(socket, message) do
    :ok = :gen_tcp.send(socket, message)
    :gen_tcp.recv(socket, 0, 1000)
  end
end
