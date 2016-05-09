defmodule AcmeUdpLogger.MessageReceiver do
  use GenServer
  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init (:ok) do
    {:ok, _socket} = :gen_udp.open(21337)
  end

  # Handle UDP data
  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    message = parse_packet(data)
    Logger.info "Received a secret message! " <> inspect(message)

    {:noreply, state}
  end

  # Ignore everything else
  def handle_info({_, _socket}, state) do
    {:noreply, state}
  end

  def parse_packet(data) do
    <<
      _header        :: size(240), # 30 bytes * 8 = 240 bits
      priority_code  :: bitstring-size(8),
      agent_number   :: little-unsigned-integer-size(32),
      message        :: bitstring-size(320)
    >> = data

    message = %{
      priority_code: priority_code,
      agent_number: agent_number,
      message: String.rstrip(message),
    }
  end
end
