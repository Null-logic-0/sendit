defmodule Sendit.Repo do
  use Ecto.Repo,
    otp_app: :sendit,
    adapter: Ecto.Adapters.Postgres
end
