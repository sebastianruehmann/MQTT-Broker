defmodule MqttBroker.Messages.FixedHeader do
  defstruct message_type: :reserved,
            duplicate: false,
            qos: :fire_and_forget,
            retain: false,
            length: 0

  @type t :: %__MODULE__{
    message_type: atom,
    duplicate: boolean,
    qos: boolean,
    retain: boolean,
    length: pos_integer
  }

  def new(msg_type, dup, qos, retain, length) when
    is_atom(msg_type) and
    is_boolean(dup) and
    is_atom(qos) and
    is_boolean(retain) and
    is_integer(length) and
    length >= 0 do

    %__MODULE__{
      message_type: msg_type,
      duplicate: dup,
      qos: qos,
      retain: retain,
      length: length
    }
  end
end
