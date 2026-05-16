defmodule Sendit.Repo.Migrations.AddGroupChatFieldsToConversations do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add :title, :string
      add :is_group, :boolean, default: false, null: false
    end
  end
end
