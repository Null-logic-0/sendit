defmodule Sendit.Repo.Migrations.CreateConversationRead do
  use Ecto.Migration

  def change do
    create table(:conversation_read) do
      add :last_read_at, :utc_datetime
      add :conversation_id, references(:conversations, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:conversation_read, [:conversation_id, :user_id])
  end
end
