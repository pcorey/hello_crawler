defmodule HelloCrawler do

  @max_depth 3

  def handle_response(url, host, path, {:ok, %{body: body}}) do
    IO.puts("Crawling \"#{url}\"...")
    path = [url | path]
    [url | body
           |> Floki.find("a")
           |> Floki.attribute("href")
           |> Enum.map(&URI.merge(url, &1))
           |> Enum.map(&to_string/1)
           |> Enum.reject(&Enum.member?(path, &1))
           |> Enum.map(&(Task.async(fn -> get_links(URI.parse(&1), host, [&1 | path]) end)))
           |> Enum.map(&Task.await/1)
           |> List.flatten]
  end

  def handle_response(url, _host, _path, _response) do
    [url]
  end

  def get_links(url, _host, path) when length(path) > @max_depth do
    [url]
  end

  def get_links(url = %{host: host}, host, path) do
    url = to_string(url)
    headers = []
    options = [follow_redirect: true]
    response = HTTPoison.get(url, headers, options)
    handle_response(url, host, path, response)
  end

  def get_links(url, _host, _path) do
    [url]
  end

  def get_links(url) do
    url = URI.parse(url)
    get_links(url, url.host, [])
    |> Enum.map(&to_string/1)
    |> Enum.uniq
  end

end
