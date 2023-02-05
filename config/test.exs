import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :parking_pool_web, ParkingPoolWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "d2s3/7jqZyYY0cKhVQo9wvlS8xRPBjY50O7+dO6L1pi3rothb1hxBjGAVgZ1FtOk",
  server: false
