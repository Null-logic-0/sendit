defmodule Sendit.Chat.Conversations do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sendit.Accounts.User
  alias Sendit.Chat.Message

  schema "conversations" do
    field :last_message_at, :utc_datetime
    field :title, :string
    field :is_group, :boolean, default: false
    field :creator_id, :id
    field :messages_count, :integer, virtual: true

    has_many :messages, Message, foreign_key: :conversation_id

    many_to_many :users, User,
      join_through: "conversation_participants",
      join_keys: [conversation_id: :id, user_id: :id]

    timestamps(type: :utc_datetime)
  end

  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:last_message_at, :title, :is_group, :creator_id])
    |> maybe_require_title()
  end

  def create_changeset(conversation, users, attrs \\ %{}) do
    conversation
    |> changeset(attrs)
    |> put_assoc(:users, users)
  end

  defp maybe_require_title(changeset) do
    if get_field(changeset, :is_group) do
      changeset
      |> validate_required([:title])
      |> validate_length(:title, min: 3, max: 100)
    else
      changeset
    end
  end
end
