defmodule Harbor.Pds do

	@max_file_size 52428800

	def get_blob(pds, did, cid) do
		url = "#{pds}/xrpc/com.atproto.sync.getBlob?did=#{did}&cid=#{cid}"
		with { :ok, size } <- get_content_length_header(url),
			size <= @max_file_size do
			case HTTPoison.get(url) do
				{ :ok, %{ status_code: 200, body: body} } ->
					{ :ok, body }
				_ ->
					{ :error, "Could not get blob" }
			end
		else
			{ :error, err } ->
				{ :error, err }
		end

	end

	def get_content_length_header(url) do
		case HTTPoison.head(url) do
			{ :ok, %{ status_code: 200, headers: headers }} ->
				{ _, size } = headers |>
					Enum.find(fn { key, _ } ->
						String.match?(key, ~r/content-length/i)
					end)

				{ :ok, Integer.parse(size) }
			_ ->
				{ :error, "PDS does not resport the size of the blob." }
		end
	end

end
