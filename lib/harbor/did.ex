defmodule Harbor.Did do

  def get_pds(did) do
    case get_did_document(did) do
      { :ok, doc } ->
        svc = doc["service"] |> Enum.find fn x -> x["id"] == "#atproto_pds" end
        { :ok, svc["serviceEndpoint"] }

      { :error, err } ->
        { :error, err }
    end
  end

	def get_did_document(did) do
    case Regex.run(~r/^did:(plc|web):([a-zA-Z0-9.\-_:%]+)$/, did) do
      [_, "plc", _] ->
        get_plc_document(did)

      [_, "web", url] ->
        get_web_document(url)

      nil ->
        { :error, "Not a valid DID" }  
    end
  end

  def get_plc_document(did) do
    case HTTPoison.get("https://plc.directory/#{did}") do
      { :ok, %{ status_code: 200, body: body } } ->
        { :ok, Poison.decode! body }
      _ ->
        { :error, "Could not fetch plc did." }
    end
  end

  def get_web_document(url) do
    case HTTPoison.get("https://#{url}/.well-known/did.json") do
      { :ok, %{ status_code: 200, body: body } } ->
        { :ok, Poison.decode! body }
      _ ->
        { :error, "Could not fetch web did." }
    end
  end

end