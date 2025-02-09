# Harbor 🚢⚓

Harbor is a fast caching blob proxy service for the ATProto written in Elixir. It was written to replace `cdn.bsky.app` for [PinkSea](https://github.com/shinolabs/PinkSea)

## Usage

### Docker (recommended)

After cloning the repository, navigate to it and then create a folder called `cache`. After that run `docker compose up -d` to build and run the harbor image.

The service will be exposed via the port `4001` by default, you can change it by editing the `docker-compose.yml` file.

### Manual installation

After cloning the repo, navigate to the folder. Inside of it run `mix deps.get` to download the neccessary dependencies. Once it's done, run `mix run --no-halt` to run harbor. The service will start on port 4001.

To get a blob navigate to `http://localhost:4001/<did>/<cid>`. The blob will be fetched and cached inside of the `./cache` folder.

## License

Harbor is licensed under the MIT license.