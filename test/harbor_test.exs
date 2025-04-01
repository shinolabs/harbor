defmodule HarborTest do
  use ExUnit.Case
  use Mimic

  defmodule HTTPoisonFixture do
    @plc_data File.read!("test/fixtures/plc.json")
    @pds_data File.read!("test/fixtures/pds.json")

    def get(url) do
      case url do
        "https://plc.directory/did:plc:ewvi7nxzyoun6zhxrhs64oiz" ->
          {:ok, %HTTPoison.Response{status_code: 200, body: @plc_data}}

        "https://example.com/.well-known/did.json" ->
          {:ok, %HTTPoison.Response{status_code: 200, body: @pds_data}}

        "https://pds.example.com/xrpc/com.atproto.sync.getBlob?did=did:web:example.com&cid=123" ->
          {:ok, %HTTPoison.Response{status_code: 200, body: "blob data"}}

        "https://pds.example.com/xrpc/com.atproto.sync.getBlob?did=did:web:example.com&cid=big" ->
          {:ok, %HTTPoison.Response{status_code: 200, body: "huge blob data"}}

        "https://pds.example.com/xrpc/com.atproto.sync.getBlob?did=did:web:example.com&cid=gonefishing" ->
          {:ok, %HTTPoison.Response{status_code: 503}}

        _ ->
          {:error, %HTTPoison.Response{status_code: 404}}
      end
    end

    def head(url) do
      case url do
        "https://pds.example.com/xrpc/com.atproto.sync.getBlob?did=did:web:example.com&cid=123" ->
          {:ok, %HTTPoison.Response{status_code: 200, headers: [{"content-length", "123"}]}}

        "https://pds.example.com/xrpc/com.atproto.sync.getBlob?did=did:web:example.com&cid=big" ->
          {:ok, %HTTPoison.Response{status_code: 200, headers: [{"content-length", "52428801"}]}}

        "https://pds.example.com/xrpc/com.atproto.sync.getBlob?did=did:web:example.com&cid=gonefishing" ->
          {:ok, %HTTPoison.Response{status_code: 200, headers: [{"content-length", "11"}]}}

        "https://pds.example.com/xrpc/com.atproto.sync.getBlob?did=did:web:example.com&cid=invalidsize" ->
          {:ok, %HTTPoison.Response{status_code: 200, headers: [{"content-length", "invalid"}]}}

        _ ->
          {:error, %HTTPoison.Response{status_code: 404}}
      end
    end
  end

  setup do
    Cachex.clear(:harbor_cache)
    stub_with(HTTPoison, HTTPoisonFixture)
    :ok
  end

  test "invalid did" do
    assert {:error, "Not a valid DID"} = Harbor.Did.get_pds("did:example:123")
    assert {:error, "Could not fetch plc did."} = Harbor.Did.get_pds("did:plc:123")
    assert {:error, "Could not fetch web did."} = Harbor.Did.get_pds("did:web:blueskyweb.xyz")
  end

  test "did plc to pds" do
    assert {:ok, "https://enoki.us-east.host.bsky.network"} = Harbor.Did.get_pds("did:plc:ewvi7nxzyoun6zhxrhs64oiz")
  end

  test "did web to pds" do
    assert {:ok, "https://pds.example.com"} = Harbor.Did.get_pds("did:web:example.com")
  end

  test "did web to pds cache" do
    assert {:ok, "https://pds.example.com"} = Harbor.Did.get_pds("did:web:example.com")
    assert {:ok, "https://pds.example.com"} = Cachex.get(:harbor_cache, "did:web:example.com")
    assert {:ok, "https://pds.example.com"} = Harbor.Did.get_pds("did:web:example.com")
  end

  test "fetch blob from pds" do
    assert {:ok, "blob data"} = Harbor.Pds.get_blob("https://pds.example.com", "did:web:example.com", "123")
  end

  test "fetch blob from pds with size constraint" do
    assert {:error, "Blob is too large"} = Harbor.Pds.get_blob("https://pds.example.com", "did:web:example.com", "big")
  end

  test "failed fetch blob but size retreived" do
    assert {:error, "Could not get blob"} =
             Harbor.Pds.get_blob("https://pds.example.com", "did:web:example.com", "gonefishing")
  end

  test "failed fetch blob" do
    assert {:error, "PDS does not report the size of the blob."} =
             Harbor.Pds.get_blob("https://pds.example.com", "did:web:example.com", "unknown")

    assert {:error, "PDS does not report the size of the blob."} =
             Harbor.Pds.get_blob("https://pds.example.com", "did:web:example.com", "invalidsize")
  end
end
