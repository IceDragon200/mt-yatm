local Vector4 = assert(foundation.com.Vector4)
local Subject = assert(yatm_radio_network.RadioNetwork)

local case = foundation.com.Luna:new("yatm_radio_network.RadioNetwork")

case:describe("#initialize/0", function (t2)
  t2:test("can initialize a new radio network", function (t3)
    local subject = Subject:new()

    t3:assert(subject)
  end)
end)

case:describe("#update/1", function (t2)
  t2:test("can safely update with no objects", function (t3)
    local subject = Subject:new()

    for _ = 1,10 do
      subject:update(0.10)
    end
  end)

  t2:test("can safely handle an expired subscriber", function (t3)
    local subject = Subject:new()

    local addr = "somethingsomething"
    subject:subscribe_for_messages(Vector4.new(0, 0, 0, 1), addr, 1)
    t3:assert(subject:has_subscribers())
    for _ = 1,11 do
      subject:update(0.10)
    end

    t3:refute(subject:has_subscribers())
  end)

  t2:test("can safely handle an expired mailbox", function (t3)
    local subject = Subject:new()

    local addr = "somethingsomething"
    subject:request_mailbox_id(addr, 1)
    t3:assert(subject:has_mailboxes())
    for _ = 1,11 do
      subject:update(0.10)
    end

    t3:refute(subject:has_mailboxes())
  end)

  t2:test("can populate and process a mailbox", function (t3)
    local subject = Subject:new()

    local addr = "somethingsomething"
    local mailbox_id = subject:request_mailbox_id(addr, 5)
    t3:assert(mailbox_id, "we should have a mailbox id")
    t3:assert(subject:has_mailboxes(), "there should be mailboxes")
    subject:publish_message(addr, "Hello, World", 12)
    subject:publish_message(addr, "Goodbye, Universe", 2)
    subject:update(0.10)
    local message, meta = subject:get_next_mailbox_message(mailbox_id, addr)
    t3:assert_eq(message, "Hello, World")
    t3:assert_eq(meta, 12)
    message, meta = subject:get_next_mailbox_message(mailbox_id, addr)
    t3:assert_eq(message, "Goodbye, Universe")
    t3:assert_eq(meta, 2)
    message, meta = subject:get_next_mailbox_message(mailbox_id, addr)
    t3:refute(message)
    t3:refute(meta)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
