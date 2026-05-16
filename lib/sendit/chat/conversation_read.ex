defmodule Sendit.Chat.ConversationRead do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sendit.Accounts.User
  alias Sendit.Chat.Conversations

  schema "conversation_read" do
    field :last_read_at, :utc_datetime

    belongs_to :user, User
    belongs_to :conversation, Conversations

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation_read, attrs, user_scope) do
    conversation_read
    |> cast(attrs, [:last_read_at, :conversation_id])
    |> validate_required([:last_read_at, :conversation_id])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint([:conversation_id, :user_id])
  end
end
