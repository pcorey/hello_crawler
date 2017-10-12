defmodule HelloCrawler do

  @default_max_depth 3
  @default_headers []
  @default_options [follow_redirect: true]

  def get_links(url, opts \\ []) do
    url = URI.parse(url)
    context = %{
      max_depth: Keyword.get(opts, :max_depth, @default_max_depth),
      headers: Keyword.get(opts, :headers, @default_headers),
      options: Keyword.get(opts, :headers, @default_options),
      host: url.host
    }
    get_links(url, [], context)
    |> Enum.map(&to_string/1)
    |> Enum.uniq
  end

  defp get_links(url, path, context) do
    if continue_crawl?(path, context) and crawlable_url?(url, context) do
      url
      |> to_string
      |> HTTPoison.get(context.headers, context.options)
      |> handle_response(path, url, context)
    else
      [url]
    end
  end

  defp continue_crawl?(path, %{max_depth: max_depth}) when length(path) > max_depth, do: false
  defp continue_crawl?(_, _), do: true

  defp crawlable_url?(%{host: host}, %{host: initial}) when host == initial, do: true
  defp crawlable_url?(_, _), do: false

  defp handle_response({:ok, %{body: body}}, path, url, context) do
    IO.puts("Crawling \"#{url}\"...")
    path = [url | path]
    [url | body
           |> Floki.find("a")
           |> Floki.attribute("href")
           |> Enum.map(&URI.merge(url, &1))
           |> Enum.map(&to_string/1)
           |> Enum.reject(&Enum.member?(path, &1))
           |> Enum.map(&(Task.async(fn -> get_links(URI.parse(&1), [&1 | path], context) end)))
           |> Enum.map(&Task.await/1)
           |> List.flatten]
  end

  defp handle_response(_response, _path, url) do
    [url]
  end

end
