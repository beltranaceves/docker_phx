defmodule DockerPhxWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :docker_phx
  use SiteEncrypt.Phoenix

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_docker_phx_key",
    signing_salt: "GFQTbU9g"
  ]

  socket "/socket", DockerPhxWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :docker_phx,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug DockerPhxWeb.Router

  @impl SiteEncrypt
  def certification do
    SiteEncrypt.configure(
      # Note that native client is very immature. If you want a more stable behaviour, you can
      # provide `:certbot` instead. Note that in this case certbot needs to be installed on the
      # host machine.
      client: :native,

      domains: ["beltran.ninja"],
      emails: ["beltranaceves@gmail.com"],

      db_folder: Application.app_dir(:wwwsand, Path.join(~w/priv site_encrypt/)),

      # set OS env var CERT_MODE to "staging" or "production" on staging/production hosts
      directory_url: case System.get_env("CERT_MODE", "local") do
        "local" -> {:internal, port: 4002}
        "staging" -> "https://acme-staging-v02.api.letsencrypt.org/directory"
        "production" -> "https://acme-v02.api.letsencrypt.org/directory"
      end
    )
  end

  @impl Phoenix.Endpoint
  def init(_key, config) do
    # this will merge key, cert, and chain into `:https` configuration from config.exs
    {:ok, SiteEncrypt.Phoenix.configure_https(config, port: 4001)}
  end
end
