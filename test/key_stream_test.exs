defmodule KeyStreamTest do
  use ExUnit.Case
  doctest KeyStream
  use Bitwise

  test "generate from binaries" do
    Enum.each(
      [
        %{
          key: <<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF>>,
          iv: <<0x00, 0x00, 0x08, 0x56>>,
          length: 4,
          expected: <<0x8D, 0xE4, 0x97, 0x31>>
        },
        %{
          key: <<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF>>,
          iv: <<0x00, 0x00, 0x0F, 0x9B>>,
          length: 16,
          expected:
            <<0x07, 0xC8, 0x4B, 0xB7, 0x46, 0x27, 0x2C, 0xDD, 0x86, 0x6D, 0x5F, 0x30, 0xC5, 0x4F,
              0x1F, 0x04>>
        },
        %{
          key: <<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF>>,
          iv: <<0x00, 0x00, 0x0F, 0x0E>>,
          length: 16,
          expected:
            <<0xBF, 0x3F, 0x75, 0xD0, 0x8C, 0x3C, 0x5D, 0x7D, 0x9F, 0x77, 0xDB, 0x20, 0x9C, 0x16,
              0x48, 0x84>>
        },
        %{
          key: <<0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0x00>>,
          iv: <<0x00, 0x01, 0xAE, 0x33>>,
          length: 4,
          expected: <<0x48, 0xC3, 0x0C, 0xAD>>
        }
      ],
      fn %{key: key, iv: iv, length: length, expected: expected} ->
        stream = KeyStream.generate_binary(key, iv, length)
        assert stream == expected
      end
    )
  end

  test "generate from hexa" do
    Enum.each(
      [
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
      ],
      fn %{key: key, iv: iv, length: length, expected: expected} ->
        stream = KeyStream.generate_hex(key, iv, length)
        assert stream == expected
      end
    )
  end
end
