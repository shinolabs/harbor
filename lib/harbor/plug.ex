defmodule Harbor.Plug do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

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
      {:ok, blob} ->
        IO.puts("hit disk cache for #{did}/#{cid}")
        respond_with_cache(conn, did, cid, blob)

      {:error, _} ->
        case Harbor.Did.get_pds(did) do
          {:error, err} ->
            send_resp(conn, 400, err)

          {:ok, pds} ->
            case Harbor.Pds.get_blob(pds, did, cid) do
              {:ok, data} ->
                Harbor.Disk.cache_blob(did, cid, data)
                respond_with_cache(conn, did, cid, data)

              {:error, err} ->
                send_resp(conn, 400, err)
            end
        end
    end
  end

  match _ do
    send_resp(conn, 404, "Invalid path.")
  end

  defp respond_with_cache(conn, did, cid, blob) do
    with {:ok, etag} <- Harbor.Disk.get_etag_for(did, cid) do
      conn =
        conn
        |> put_resp_header("cache-control", "public, max-age=#{Application.fetch_env!(:harbor, :time_before_eviction)}")
        |> put_resp_header("etag", etag)
      if etag in get_req_header(conn, "if-none-match") do
        conn
        |> send_resp(304, "")
      else
        conn
        |> send_resp(200, blob)
      end
    else
      _ -> send_resp(conn, 500, "An unexpected error has occured.")
    end
  end
end
