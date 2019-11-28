defmodule MqttBroker.Socket do
  @callback prepare() :: :ok | :error
  @callback run(number) :: {:ok, String.t} | {:error, String.t}
  @callback accept(number) :: {:ok, String.t} | {:error, String.t}
  @callback recv(number) :: {:ok, String.t} | {:error, String.t}
  @callback send(number) :: {:ok, String.t} | {:error, String.t}
  @callback close(number) :: {:ok, String.t} | {:error, String.t}
  @callback controlling_process(number) :: {:ok, String.t} | {:error, String.t}
end
