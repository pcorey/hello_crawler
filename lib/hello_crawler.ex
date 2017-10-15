defmodule HelloCrawler do

  @default_max_depth 3
  @default_headers []
  @default_options [follow_redirect: true]
  @default_max_concurrency System.schedulers_online

  def get_links(url, opts \\ []) do
    url = URI.parse(url)
    context = %{
      max_depth: Keyword.get(opts, :max_depth, @default_max_depth),
      headers: Keyword.get(opts, :headers, @default_headers),
      options: Keyword.get(opts, :options, @default_options),
      max_concurrency: Keyword.get(opts, :max_concurrency, @default_max_concurrency),
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
           |> get_next_links(path, context)
           |> List.flatten]
  end

  defp handle_response(_response, _path, url) do
    [url]
  end

  defp get_next_links(urls, path, context) do
    Task.async_stream(urls, fn
      url ->
        get_links(URI.parse(url), [url | path], context)
    end, max_concurrency: context.max_concurrency)
    |> Enum.to_list
    |> Enum.map(&elem(&1, 1))
  end

end
