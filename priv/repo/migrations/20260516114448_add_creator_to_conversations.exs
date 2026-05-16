defmodule Sendit.Repo.Migrations.AddCreatorToConversations do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add :creator_id, references(:users, on_delete: :nilify_all)
    end
  end
end
