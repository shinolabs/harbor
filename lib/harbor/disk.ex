defmodule Harbor.Disk do
  @cache_folder "./cache"

  def get_cache_file_name(did, cid) do
    colon_less_did = String.replace(did, ":", "")
    "#{@cache_folder}/#{colon_less_did}#{cid}"
  end

  def cached?(did, cid) do
    File.exists?(get_cache_file_name(did, cid))
  end

  def get_blob_from_cache(did, cid) do
    case cached?(did, cid) do
      true ->
        case File.read(get_cache_file_name(did, cid)) do
          { :ok, binary } ->
            { :ok, binary }

          { :error, err } ->
            { :error, err }
        end

      false ->
        { :error, "File not found in cache." }
    end
  end

  def cache_blob(did, cid, data) do
    if not File.exists?(@cache_folder) do
      File.mkdir! @cache_folder
    end
    case File.write(get_cache_file_name(did, cid), data) do
      :ok ->
        IO.puts "cached #{did} #{cid}"
        { :ok, "File written" }

      { :error, err } ->
        { :error, err }
    end
  end
end
