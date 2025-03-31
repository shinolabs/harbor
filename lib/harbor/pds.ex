defmodule Harbor.Pds do
  @max_file_size 52_428_800

  def get_blob(pds, did, cid) do
    url = "#{pds}/xrpc/com.atproto.sync.getBlob?did=#{did}&cid=#{cid}"

    with {:ok, size} <- get_content_length_header(url),
         :ok <- blob_size_constraint(size) do
      case HTTPoison.get(url) do
        {:ok, %{status_code: 200, body: body}} ->
          {:ok, body}

        _ ->
          {:error, "Could not get blob"}
      end
    else
      {:error, err} ->
        {:error, err}
    end
  end

  defp blob_size_constraint(size) do
    if size <= @max_file_size do
      {:error, "Blob is too large"}
    else
      :ok
    end
  end

  defp get_content_length_header(url) do
    case HTTPoison.head(url) do
      {:ok, %{status_code: 200, headers: headers}} ->
        {_, size} =
          headers
          |> Enum.find(fn {key, _} ->
            String.match?(key, ~r/content-length/i)
          end)

        {:ok, Integer.parse(size)}

      _ ->
        {:error, "PDS does not report the size of the blob."}
    end
  end
end
