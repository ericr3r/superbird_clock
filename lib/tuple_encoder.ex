defimpl Jason.Encoder, for: Tuple do
  def encode(tuple, opts) do
    Jason.Encoder.encode(Tuple.to_list(tuple), opts)
  end
end