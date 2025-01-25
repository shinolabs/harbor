defmodule Harbor.Plug do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/:did/:cid" do
    case Harbor.Did.get_pds(did) do
      { :error, err } ->
        send_resp(conn, 400, err)
      { :ok, pds } ->
        case Harbor.Pds.get_blob(pds, did, cid) do
          { :ok, data } ->
            send_resp(conn, 200, data)

          { :error, err } ->
            send_resp(conn, 400, err)
        end 
    end
  end


  match _ do
    send_resp(conn, 404, "Invalid path.")
  end
end