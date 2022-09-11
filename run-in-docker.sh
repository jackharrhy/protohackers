#!/bin/sh
docker run -it \
  -v $(pwd):/app \
  -p 4040:4040 \
  -p 4050:4050 \
  -p 4060:4060 \
  -p 4070:4070 \
  -p 4080:4080 \
  -p 4090:4090 \
  --rm \
  -w "/app" \
  elixir \
  /bin/sh -c \
  "cd /app; mix local.hex --force; mix deps.get; iex -S mix"
