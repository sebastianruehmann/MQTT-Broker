defmodule MqttBroker.Messages.Requests.Connect do
  @moduledoc """
  Connect MQTT Message
  http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718028
  """
  defstruct client_id: "",
            user_name: "",
            password: "",
            keep_alive_ms:  :infinity,
            keep_alive_server_ms: :infinity,
            last_will: false,
            will_qos: :fire_and_forget,
            will_retain: false,
            will_topic: "",
            will_message: "",
            clean_session: true

  @type t :: %__MODULE__{
    client_id: String.t,
    user_name: String.t,
    password: String.t,
    keep_alive_ms: Skyline.keep_alive,
    keep_alive_server_ms: Skyline.keep_alive,
    last_will: boolean,
    will_qos: Skyline.qos_type,
    will_retain: boolean,
    will_topic: String.t,
    will_message: String.t,
    clean_session: boolean
  }

  def new(client_id, user_name, password, clean_session, keep_alive, keep_alive_server,
    last_will, will_qos, will_retain, will_topic, will_message) do

  	%__MODULE__{
      client_id: client_id,
      user_name: user_name,
      password: password,
      keep_alive_ms: keep_alive,
      keep_alive_server_ms: keep_alive_server,
      last_will: last_will,
      will_qos: will_qos,
      will_retain: will_retain,
      will_topic: will_topic,
      will_message: will_message,
      clean_session: clean_session
    }
  end

  def validate(<<0, 4, "MQTT",  4, flags :: size(8), keep_alive :: size(16), rest :: binary>>), do: {:ok}

  def decode_body(<<0, 4, "MQTT",  4, flags :: size(8), keep_alive :: size(16), rest :: binary>>) do
    <<user_flag :: size(1),
      pass_flag :: size(1),
      w_retain :: size(1),
      w_qos :: size(2),
      will_flag :: size(1),
      clean :: size(1),
      _ ::size(1) >> = <<flags>>

      payload = utf8_list(rest, [])
      {client_id, payload} = extract(payload)
      {will_topic, payload} = if (will_flag), do: extract(payload), else: {"", payload}
      {will_message, payload} = if (will_flag), do: extract(payload), else: {"", payload}
      {user_name, payload} = if (user_flag), do: extract(payload), else: {"", payload}
      {password, _payload} = if (pass_flag), do: extract(payload), else: {"", payload}
      {alive, alive_server} = if (keep_alive == 0) do
        {:infinity, :infinity}
      else
        {keep_alive * 1000, (keep_alive + 10) * 1000}
      end

      new(client_id, user_name, password, clean == 1, alive, alive_server,
        will_flag == 1, MqttBroker.Decoder.decode_qos(w_qos), w_retain == 1, will_topic, will_message)
  end

  def extract(list) do
    if length(list) > 1 do
      {hd(list), tl(list)}
    else
      {List.first(list), []}
    end
  end

  @spec utf8_list(binary, [String.t]) :: [String.t]
  def utf8_list(<<>>, acc) do
    Enum.reverse acc
  end
  def utf8_list(content, acc) do
    {t, rest} = utf8(content)
    utf8_list(rest, [t | acc])
  end

  @spec utf8(binary) :: String.t
  def utf8(<<length :: integer-unsigned-size(16), content :: bytes-size(length), rest :: binary>>) do
    {content, rest}
  end
  # payload:
  #clientId 1 and 23 UTF-8 encoded bytes in length
  #if w_flag: Will Topic
  #if w_flag: Will Message length 2 byte + (0->) Byte Will Message
  #if user_flag: Username
  #if pass_flag: Password length 2 byte + 0 to 65535 bytes Password
end
