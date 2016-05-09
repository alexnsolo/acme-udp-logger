defmodule AcmeUdpLoggerTest.MessageReceiver do
  use ExUnit.Case

  @header <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2>>
  @priority_code <<81>>
  @agent_number <<7, 0, 0, 0>>
  @message <<116, 104, 101, 32, 104, 101, 110, 32, 104, 97, 115, 32, 102, 108, 111, 119, 110, 32, 116, 104, 101, 32, 99, 111, 111, 112, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32>>

  test "it should extract relevant data from UDP packet" do
    packet = @header <> @priority_code <> @agent_number <> @message

    message = AcmeUdpLogger.MessageReceiver.parse_packet(packet)
    assert message
    assert message.priority_code == "Q"
    assert message.agent_number == 7
    assert message.message == "the hen has flown the coop"
  end
end
