import Config

config :harbor,
  maid_runtime_period: 1000 * 60 * 60,
  time_before_eviction: 60 * 60 * 24,
  cache_folder: "./cache"
