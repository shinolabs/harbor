FROM elixir:1.18.3-alpine as build

COPY . .

RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get && \
    mix release

RUN APP_NAME="harbor" && \
    mkdir /export && \
    cp -r _build/prod/rel/$APP_NAME/* /export

FROM erlang:27-alpine

EXPOSE 4001
ENV REPLACE_OS_VARS=true \
    PORT=4001

COPY --from=build /export/ .

ENTRYPOINT ["./bin/harbor"]
CMD ["start"]