defmodule HelloCrawlerTest do
  use ExUnit.Case
  doctest HelloCrawler

  test "greets the world" do
    assert HelloCrawler.hello() == :world
  end
end
