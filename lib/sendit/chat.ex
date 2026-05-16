defmodule Sendit.Chat do
  import Ecto.Query, warn: false
  alias Sendit.Repo
  alias Sendit.Chat.Conversations
  alias Sendit.Accounts.{Scope, User}

  def subscribe_conversation(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Sendit.PubSub, "user:#{scope.user.id}:conversation")
  end

  defp broadcast_conversations(%Scope{} = scope, message) do
    Phoenix.PubSub.broadcast(Sendit.PubSub, "user:#{scope.user.id}:conversation", message)
  end

  def list_conversations(%Scope{} = scope, params) do
    q = params["q"]

    from(c in Conversations,
      where:
        fragment(
          "? IN (SELECT cp.conversation_id FROM conversation_participants cp WHERE cp.user_id = ?)",
          c.id,
          ^scope.user.id
        ),
      order_by: [desc_nulls_last: c.last_message_at]
    )
    |> search_conversations_by(q)
    |> Repo.all()
    |> Repo.preload(:users)
  end

  defp search_conversations_by(query, q) when q in ["", nil], do: query

  defp search_conversations_by(query, q) do
    where(
      query,
      [c],
      ilike(c.title, ^"%#{q}%") or
        fragment(
          "EXISTS (
            SELECT 1 FROM conversation_participants cp
            JOIN users u ON u.id = cp.user_id
            WHERE cp.conversation_id = ? AND (
              u.username ILIKE ? OR u.full_name ILIKE ?
            )
          )",
          c.id,
          ^"%#{q}%",
          ^"%#{q}%"
        )
    )
  end

  def get_conversation!(%Scope{} = scope, id) do
    from(c in Conversations,
      join: p in "conversation_participants",
      on: p.conversation_id == c.id,
      where: c.id == ^id and p.user_id == ^scope.user.id,
      preload: :users
    )
    |> Repo.one!()
  end

  def get_or_create_conversation(%Scope{} = scope, %User{} = other_user) do
    existing =
      from(c in Conversations,
        join: p1 in "conversation_participants",
        on: p1.conversation_id == c.id,
        join: p2 in "conversation_participants",
        on: p2.conversation_id == c.id,
        where: p1.user_id == ^scope.user.id,
        where: p2.user_id == ^other_user.id,
        where: c.is_group == false,
        where:
          fragment(
            "(SELECT COUNT(*) FROM conversation_participants cp WHERE cp.conversation_id = ?) = 2",
            c.id
          ),
        limit: 1
      )
      |> Repo.one()

    case existing do
      %Conversations{} = conv -> {:ok, conv}
      nil -> create_conversation(scope, [scope.user, other_user], %{is_group: false})
    end
  end

  def create_group_conversation(%Scope{} = scope, user_ids, title)
      when is_list(user_ids) and length(user_ids) >= 2 do
    other_users = Repo.all(from u in User, where: u.id in ^user_ids)
    all_users = [scope.user | other_users] |> Enum.uniq_by(& &1.id)

    create_conversation(scope, all_users, %{is_group: true, title: title})
  end

  defp create_conversation(%Scope{} = scope, users, attrs) when is_list(users) do
    with {:ok, conversation} <-
           %Conversations{}
           |> Conversations.create_changeset(users, attrs)
           |> Repo.insert() do
      broadcast_conversations(scope, {:created, conversation})

      {:ok, conversation}
    end
  end

  def delete_conversation(%Scope{} = scope, id) do
    conversation = get_conversation!(scope, id)

    with {:ok, deleted} <- Repo.delete(conversation) do
      broadcast_conversations(scope, {:deleted, deleted})
      {:ok, deleted}
    end
  end

  def list_users(params \\ []) do
    User
    |> search_by(params["q"])
    |> Repo.all()
  end

  defp search_by(query, q) when q in ["", nil], do: query

  defp search_by(query, q) do
    where(query, [u], ilike(u.username, ^"%#{q}%") or ilike(u.full_name, ^"%#{q}%"))
  end
end
