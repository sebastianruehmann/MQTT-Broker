defmodule MqttBroker.Decoder do
  use Bitwise
  alias MqttBroker.Messages.FixedHeader
  alias MqttBroker.Messages.Requests

  def decode(msg) do
    msg
    |> decode_fixed_header
    |> decode_message
  end

  defp decode_fixed_header(<<type :: size(4), dup :: size(1), qos :: size(2),
                 retain :: size(1), remaining :: binary>>) do
    { length, remaining } = decode_length(remaining)
    {
      remaining,
      FixedHeader.new(
        decode_message_type(type),
        (dup == 1),
        decode_qos(qos),
        (retain == 1),
        length
      )
    }
  end

  def decode_message({ msg, _ = %FixedHeader{message_type: msg_type}}) do
    message = case msg_type do
      :connect -> Requests.Connect
    end

    try do
      message.decode_body(msg)
    rescue
      _ in FunctionClauseError -> "Not valid request"
    end
  end

  @spec decode_packet_id(binary) :: pos_integer
  def decode_packet_id(<<id :: unsigned-integer-size(16)>>) do
    id
  end

  def decode_qos(binary_qos) do
    case binary_qos do
      0 -> :fire_and_forget
      1 -> :at_least_once
      2 -> :exactly_once
      3 -> :reserved
    end
  end

  defp decode_message_type(binary_msg_type) do
    case binary_msg_type do
        0 -> :reserved
        1 -> :connect
        2 -> :conn_ack
        3 -> :publish
        4 -> :pub_ack
        5 -> :pub_rec
        6 -> :pub_rel
        7 -> :pub_comp
        8 -> :subscribe
        9 -> :sub_ack
        10 -> :unsubscribe
        11 -> :sub_ack
        12 -> :ping_req
        13 -> :ping_resp
        14 -> :disconnect
        15 -> :reserved
    end
  end

  defp decode_length(<<overflow :: size(1), len :: size(7), remaining :: binary>>) do
      case overflow do
        1 ->
          len + (decode_length(remaining) <<< 7)
        0 -> { len, remaining }
      end
    end
end
