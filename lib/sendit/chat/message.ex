defmodule Sendit.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sendit.Chat.Conversations
  alias Sendit.Accounts.User

  schema "messages" do
    field :body, :string

    belongs_to :conversation, Conversations
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs, user_scope) do
    message
    |> cast(attrs, [:body, :conversation_id])
    |> validate_required([:body, :conversation_id])
    |> validate_length(:body, max: 500)
    |> put_change(:user_id, user_scope.user.id)
    |> foreign_key_constraint(:conversation_id)
    |> foreign_key_constraint(:user_id)
  end
end
