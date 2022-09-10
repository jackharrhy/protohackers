#!/bin/sh
docker run -it \
  -v $(pwd):/app \
  -p 4040:4040 \
  -p 4050:4050 \
  --rm \
  -w "/app" \
  elixir \
  /bin/sh -c \
  "cd /app; mix local.hex --force; mix deps.get; iex -S mix"
