defmodule SuperbirdClockTest do
  use ExUnit.Case
  doctest SuperbirdClock

  test "greets the world" do
    assert SuperbirdClock.hello() == :world
  end
end
