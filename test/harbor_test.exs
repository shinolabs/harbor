defmodule HarborTest do
  use ExUnit.Case
  doctest Harbor

  test "greets the world" do
    assert Harbor.hello() == :world
  end
end
