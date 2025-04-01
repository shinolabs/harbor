defmodule Harbor.Maid do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    IO.puts("Maid sweeping old cached files...")

    Path.wildcard("#{Harbor.Disk.cache_folder()}/*")
    |> Enum.map(fn x ->
      %{atime: atime} = File.stat!(x)
      {x, atime}
    end)
    |> Enum.filter(fn {_, atime} ->
      secs_file = :calendar.datetime_to_gregorian_seconds(atime)
      secs_now = :calendar.datetime_to_gregorian_seconds(:calendar.universal_time())

      secs_now - secs_file >= Application.fetch_env!(:harbor, :time_before_eviction)
    end)
    |> Enum.each(fn {file, _} ->
      IO.puts("\t- Removing #{file}...")

      File.rm(file)
    end)

    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, Application.fetch_env!(:harbor, :maid_runtime_period))
  end
end
