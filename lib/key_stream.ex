defmodule KeyStream do

  use Bitwise

  @r_mask   0x0000d2a8415a0aac1d5363d5
  @comp_0   0x00003fea7942a8096aa97a30
  @comp_1   0x00003dd7e3a21d63dd629e9a
  @s_mask_0 0x00005802af4a93819ffa7faf
  @s_mask_1 0x0000c52b4911b0634c8cb877
  defstruct  r: 0, s: 0

  def generate_binary(key, iv, length) do
    {key, _} = key |> Base.encode16 |> Integer.parse(16)
    {iv, _}  = iv |> Base.encode16 |> Integer.parse(16)
    generate(key, iv, length)
  end

  def generate_hex(key, iv, length) do
    {key, _} = key  |> Integer.parse(16)
    {iv, _}  = iv  |> Integer.parse(16)
    generate(key, iv, length) |> Base.encode16 |> String.downcase
  end

  defp generate(key, iv, length) do
    ctx = setup(%KeyStream{}, key, iv)

    {_ctx, bytes} = Enum.reduce(1..length, {ctx, <<>> }, fn(_, {ctx, bytes}) ->
      {ctx, byte} = keystream_byte(ctx)
      {ctx, bytes <> <<byte>>}
    end )
    bytes
  end

  defp clock_r(r, input_bit_r, control_bit_r) do
    feedback_bit = extract_bit(r, 79) ^^^ input_bit_r
    r = if (control_bit_r == 1) do
     r ^^^ (r <<< 1)
    else
     r <<< 1
    end
    if (feedback_bit == 1), do: r ^^^ @r_mask, else: r
  end

  defp clock_s(s, input_bit_s, control_bit_s) do
    feedback_bit = extract_bit(s, 79) ^^^ input_bit_s
    s = (s <<< 1) ^^^ (((s ^^^ @comp_0) &&& ((s >>> 1) ^^^ @comp_1)) &&&  0x7fff_ffff_ffff_ffff_fffe)
    if feedback_bit == 1 do
      if control_bit_s == 1 do
        s ^^^ @s_mask_1
      else
        s ^^^ @s_mask_0
      end
    else
      s
    end

  end

  defp clock_kg(ctx, mixing, input_bit) do
    control_bit_r = (extract_bit(ctx.s, 27) ^^^ extract_bit(ctx.r, 53)) #&&& 1
    control_bit_s = (extract_bit(ctx.s, 53) ^^^ extract_bit(ctx.r, 26)) #&&& 1
    ctx = if (mixing == 1) do
      %{ ctx | r: clock_r(ctx.r, extract_bit(ctx.s, 40) ^^^ input_bit, control_bit_r) }
    else
      %{ ctx | r: clock_r(ctx.r, input_bit, control_bit_r) }
    end

    %{ ctx | s: clock_s(ctx.s, input_bit, control_bit_s) }
  end

  defp load(ctx, _binary, 0) do
    ctx
  end
  defp load(ctx, binary, size) do
    ctx = clock_kg(ctx, 1, binary &&& 1)
    load(ctx, binary >>> 1, size - 1)
  end

  defp setup(ctx, key, iv) do
    ctx = load(ctx, iv, 32)
    ctx = load(ctx, key, 80)
    pre_clock(ctx, 0, 80)
  end

  defp pre_clock(ctx, _binary, 0) do
    ctx
  end
  defp pre_clock(ctx, binary, size) do
    ctx = clock_kg(ctx, 1, binary &&& 1)
    pre_clock(ctx, binary >>> 1, size - 1)
  end

  defp keystream_byte(ctx) do
    Enum.reduce(0..7, {ctx, 0} ,fn(_, {ctx, byte}) ->
      byte = byte <<< 1
      byte = byte ^^^ current_keystream_bit(ctx)
      ctx  = clock_kg(ctx, 0, 0)
      {ctx, byte}
    end)
  end

  defp current_keystream_bit(ctx), do: extract_bit(ctx.r, 0) ^^^ extract_bit(ctx.s, 0)

  defp extract_bit(binary, pos) do
    (binary &&& (1 <<< pos)) >>> pos
  end

end
