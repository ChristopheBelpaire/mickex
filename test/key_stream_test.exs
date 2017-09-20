defmodule KeyStreamTest do
  use ExUnit.Case
  doctest KeyStream
  use Bitwise

  test "generate from binaries" do
    Enum.each([
      %{
        key: <<0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff>>,
        iv:  <<0x00, 0x00, 0x08, 0x56>>,
        length: 4,
        expected: <<0x8d, 0xe4, 0x97, 0x31>>
      },
      %{
        key: <<0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff>>,
        iv: <<0x00, 0x00, 0x0f, 0x9b >>,
        length: 16,
        expected: <<0x07, 0xc8, 0x4b, 0xb7, 0x46, 0x27, 0x2c, 0xdd, 0x86, 0x6d, 0x5f, 0x30, 0xc5, 0x4f, 0x1f, 0x04>>
      },
      %{
        key: <<0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff>>,
        iv: <<0x00,0x00,0x0f,0x0e>>,
        length: 16,
        expected: <<0xbf, 0x3f, 0x75, 0xd0, 0x8c, 0x3c, 0x5d, 0x7d, 0x9f, 0x77, 0xdb, 0x20, 0x9c, 0x16, 0x48, 0x84>>
      },
      %{
        key: <<0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0x00>>,
        iv: <<0x00, 0x01, 0xae, 0x33>>,
        length: 4,
        expected: <<0x48, 0xc3, 0x0c, 0xad>>
      }
    ], fn(%{key: key, iv: iv, length: length, expected: expected}) ->
      stream = KeyStream.generate_binary(key, iv, length)
      assert  stream == expected
    end)
  end

  test "generate from hexa" do
    Enum.each([
      %{
        key: "ffffffffffffffffffff",
        iv: "00000856",
        length: 4,
        expected: "8de49731"
      },
      %{
        key: "FFFFFFFFFFFFFFFFFFFF",
        iv: "00000f9b",
        length: 16,
        expected: "07c84bb746272cdd866d5f30c54f1f04"
      },
      %{
        key: "ffffffffffffffffffff",
        iv: "00000f0e",
        length: 16,
        expected: "bf3f75d08c3c5d7d9f77db209c164884"
      },
      %{
        key: "11223344556677889900",
        iv: "0001ae33",
        length: 4,
        expected: "48c30cad"
      }
    ], fn(%{key: key, iv: iv, length: length, expected: expected}) ->
      stream = KeyStream.generate_hex(key, iv, length)
      assert  stream == expected
    end)
  end

end
