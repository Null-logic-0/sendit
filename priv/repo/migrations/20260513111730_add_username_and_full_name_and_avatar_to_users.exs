defmodule Sendit.Repo.Migrations.AddUsernameAndFullNameAndAvatarToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :full_name, :string
      add :username, :string
      add :avatar, :string
    end

    create unique_index(:users, [:username])
  end
end
