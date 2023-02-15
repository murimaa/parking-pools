import Config

if config_env() == :prod do
  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.


  reservation_time_minutes = System.get_env("RESERVATION_TIME_MINUTES") ||
    raise """
    environment variable RESERVATION_TIME_MINUTES is missing.
    """

  config :parking_pool,
         reservation_time: String.to_integer(reservation_time_minutes) * 60_000

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  scheme = System.get_env("PUBLIC_SCHEME") || "https"

  config :parking_pool_web, ParkingPoolWeb.Endpoint,
    # Public url of app
    url: [
      host: System.get_env("PUBLIC_HOST") || "localhost",
      port: String.to_integer(System.get_env("PUBLIC_PORT") || System.get_env("PORT") || "4000"),
      scheme: scheme
    ],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base

  tenant_id = System.get_env("MICROSOFT_LOGIN_TENANT_ID") || ""
  client_id = System.get_env("MICROSOFT_LOGIN_CLIENT_ID") || ""
  client_secret = System.get_env("MICROSOFT_LOGIN_CLIENT_SECRET") || ""

  login_callback_url =
    System.get_env("MICROSOFT_LOGIN_CALLBACK_URL") ||
      "#{scheme}://#{System.get_env("PUBLIC_HOST")}/auth/microsoft/callback"

  logout_callback_url =
    System.get_env("MICROSOFT_LOGOUT_CALLBACK_URL") ||
      "#{scheme}://#{System.get_env("PUBLIC_HOST")}/auth/microsoft/logout"

  config :azure_ad_openid, AzureADOpenId,
    tenant: tenant_id,
    client_id: client_id,
    client_secret: client_secret

  config :oauth_azure_activedirectory, OauthAzureActivedirectory.Client,
    client_id: client_id,
    client_secret: client_secret,
    tenant: tenant_id,
    scope: "openid profile",
    redirect_uri: login_callback_url,
    logout_redirect_url: logout_callback_url

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :parking_pool_web, ParkingPoolWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :parking_pool_web, ParkingPoolWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your endpoint, ensuring
  # no data is ever sent via http, always redirecting to https:
  #
  #     config :parking_pool_web, ParkingPoolWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :parking_pool_web, ParkingPoolWeb.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.

  config :parking_pool_web, ParkingPoolWeb.Endpoint, server: true
end
