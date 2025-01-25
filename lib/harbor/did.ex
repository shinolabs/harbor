defmodule Harbor.Did do

	def get_did_document(did) do
    if not String.match?(did, ~r/^did:/) do
      { :error, "Not a did" }
    else
      get_plc_document(did)
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

  def get_web_document(did) do

  end

end