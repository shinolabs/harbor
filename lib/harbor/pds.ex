defmodule Harbor.Pds do
	
	def get_blob(pds, did, cid) do
		case HTTPoison.get("#{pds}/xrpc/com.atproto.sync.getBlob?did=#{did}&cid=#{cid}") do
			{ :ok, %{ status_code: 200, body: body} } ->
				{ :ok, body }
			_ ->
				{ :error, "Could not get blob" }
		end
	end

end