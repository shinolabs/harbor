defmodule Harbor.Plug do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, """
     _
    /|\\
   /_|_\\      harbor is running, choo choo~
 ____|____    https://github.com/shinolabs/harbor
 \\_o_o_o_/
~~ |     ~~~~~
___t_________

    """)
  end

  get "/:did/:cid" do
    case Harbor.Disk.get_blob_from_cache(did, cid) do
      { :ok, blob } ->
        IO.puts "hit disk cache for #{did}/#{cid}"
        send_resp(conn, 200, blob)

      { :error, _ } ->
        case Harbor.Did.get_pds(did) do
          { :error, err } ->
            send_resp(conn, 400, err)
          { :ok, pds } ->
            case Harbor.Pds.get_blob(pds, did, cid) do
              { :ok, data } ->
                Harbor.Disk.cache_blob(did, cid, data)
                send_resp(conn, 200, data)

              { :error, err } ->
                send_resp(conn, 400, err)
            end
        end
    end
  end


  match _ do
    send_resp(conn, 404, "Invalid path.")
  end
end
