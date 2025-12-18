-- Test file for parser module
-- Run with: nvim --headless -c "luafile tests/test_parser.lua"

-- Add the lua directory to package path
package.path = package.path .. ";/home/hertelp/paraglide.nvim/lua/?.lua"

local parser = require("paraglide.parser")

local function test_find_message_calls()
  print("\n=== Testing find_message_calls ===")

  local tests = {
    {
      line = 'm.hello_world()',
      expected_count = 1,
      expected_key = "hello_world",
    },
    {
      line = 'm.greeting({name: "John"})',
      expected_count = 1,
      expected_key = "greeting",
    },
    {
      line = 'm["message.with.dots"]()',
      expected_count = 1,
      expected_key = "message.with.dots",
    },
    {
      line = "m['message.key']()",
      expected_count = 1,
      expected_key = "message.key",
    },
    {
      line = 'const msg = m.hello() + m.world()',
      expected_count = 2,
      expected_key = "hello", -- first call
    },
    {
      line = '<span>{m.label()}</span>',
      expected_count = 1,
      expected_key = "label",
    },
  }

  for i, test in ipairs(tests) do
    local calls = parser.find_message_calls(test.line)
    local count = #calls

    if count == test.expected_count then
      print("✓ Test " .. i .. " passed (found " .. count .. " calls)")
    else
      print("✗ Test " .. i .. " FAILED - expected " .. test.expected_count .. " calls, got " .. count)
    end

    if count > 0 and calls[1].key ~= test.expected_key then
      print("  ERROR: expected first key '" .. test.expected_key .. "', got '" .. calls[1].key .. "'")
    end
  end
end

test_find_message_calls()
