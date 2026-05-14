defmodule Sendit.Chat.Conversations do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sendit.Accounts.User

  schema "conversations" do
    field :last_message_at, :utc_datetime

    many_to_many :users, User,
      join_through: "conversation_participants",
      join_keys: [conversation_id: :id, user_id: :id]

    timestamps(type: :utc_datetime)
  end

  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:last_message_at])
  end

  def create_changeset(conversation, users) do
    conversation
    |> changeset(%{})
    |> put_assoc(:users, users)
  end
end
