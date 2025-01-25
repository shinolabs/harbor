defmodule Harbor.Plug do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/:did/:cid" do
    case Harbor.Did.get_did_document(did) do
      { :error, err } ->
        send_resp(conn, 400, err)
      { :ok, body } ->
        send_resp(conn, 200, Poison.encode!(body))
    end
  end


  match _ do
    send_resp(conn, 404, "Invalid path.")
  end
end