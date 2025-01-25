defmodule Harbor.Plug do
	use Plug.Router

	plug :match
	plug :dispatch

	get "/" do
		send_resp(conn, 200, "hi!")
	end

	match _ do
		send_resp(conn, 404, "Invalid path.")
	end
end