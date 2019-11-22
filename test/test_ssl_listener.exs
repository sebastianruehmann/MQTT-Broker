defmodule MqttBrokerTest do
  use ExUnit.Case


  setup do
    :ssl.start()
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :ssl.connect('localhost', 1883, opts)
    %{socket: socket}
  end

  test "ssl tcp listener", %{socket: socket} do
    connect = <<16, 22, 0, 4, 77, 81, 84, 84, 4, 2, 0, 60, 0, 10, 109, 113, 116, 116, 67, 108,
  105, 101, 110, 116>>
    assert send_msg(socket, "") == {:error, :timeout}
    assert send_msg(socket, connect) == {:error, :closed}
  end

  defp send_msg(socket, message) do
    :ok = :ssl.send(socket, message)
    :ssl.recv(socket, 0, 1000)
  end
end
