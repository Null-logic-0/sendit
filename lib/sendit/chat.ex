defmodule Sendit.Chat do
  import Ecto.Query, warn: false
  alias Sendit.Repo
  alias Sendit.Chat.Conversations
  alias Sendit.Chat.ConversationRead
  alias Sendit.Accounts.{Scope, User}
  alias Sendit.Chat.Message

  def subscribe_conversation(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Sendit.PubSub, "user:#{scope.user.id}:conversation")
  end

  def list_conversations(%Scope{} = scope, params) do
    q = params["q"]

    conversations =
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
      |> Repo.preload(
        users: from(u in Sendit.Accounts.User, where: u.id != ^scope.user.id),
        messages:
          from(m in Sendit.Chat.Message,
            order_by: [desc: m.inserted_at],
            limit: 1,
            preload: :user
          )
      )

    ids = Enum.map(conversations, & &1.id)

    unread_counts =
      from(m in Message,
        left_join: r in ConversationRead,
        on: r.conversation_id == m.conversation_id and r.user_id == ^scope.user.id,
        where: m.conversation_id in ^ids,
        where: is_nil(r.last_read_at) or m.inserted_at > r.last_read_at,
        group_by: m.conversation_id,
        select: {m.conversation_id, count(m.id)}
      )
      |> Repo.all()
      |> Map.new()

    Enum.map(conversations, fn c ->
      %{c | messages_count: Map.get(unread_counts, c.id, 0)}
    end)
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
      %Conversations{} = conv ->
        {:ok, conv}

      nil ->
        create_conversation(scope, [scope.user, other_user], %{
          is_group: false,
          creator_id: scope.user.id
        })
    end
  end

  def create_group_conversation(%Scope{} = scope, user_ids, title)
      when is_list(user_ids) and length(user_ids) >= 2 do
    other_users = Repo.all(from u in User, where: u.id in ^user_ids)
    all_users = [scope.user | other_users] |> Enum.uniq_by(& &1.id)

    create_conversation(scope, all_users, %{
      is_group: true,
      title: title,
      creator_id: scope.user.id
    })
  end

  defp create_conversation(%Scope{} = _scope, users, attrs) when is_list(users) do
    with {:ok, conversation} <-
           %Conversations{}
           |> Conversations.create_changeset(users, attrs)
           |> Repo.insert() do
      conversation = Repo.preload(conversation, [:users, messages: []])

      Enum.each(conversation.users, fn user ->
        Phoenix.PubSub.broadcast(
          Sendit.PubSub,
          "user:#{user.id}:conversation",
          {:created, conversation}
        )
      end)

      {:ok, conversation}
    end
  end

  def delete_conversation(%Scope{} = scope, id) do
    conversation = get_conversation!(scope, id)

    # Delete conversation_read rows first to avoid FK constraint
    Repo.delete_all(
      from(r in Sendit.Chat.ConversationRead, where: r.conversation_id == ^conversation.id)
    )

    with {:ok, deleted} <- Repo.delete(conversation) do
      Enum.each(conversation.users, fn user ->
        Phoenix.PubSub.broadcast(
          Sendit.PubSub,
          "user:#{user.id}:conversation",
          {:deleted, deleted}
        )
      end)

      {:ok, deleted}
    end
  end

  def list_users(%Scope{} = scope, params \\ %{}) do
    User
    |> where([u], u.id != ^scope.user.id)
    |> search_by(params["q"])
    |> Repo.all()
  end

  defp search_by(query, q) when q in ["", nil], do: query

  defp search_by(query, q) do
    where(query, [u], ilike(u.username, ^"%#{q}%") or ilike(u.full_name, ^"%#{q}%"))
  end

  alias Sendit.Chat.Message
  alias Sendit.Accounts.Scope

  def subscribe_messages(conversation_id) do
    Phoenix.PubSub.subscribe(Sendit.PubSub, "conversation:#{conversation_id}:messages")
  end

  defp broadcast_message(conversation_id, message) do
    Phoenix.PubSub.broadcast(
      Sendit.PubSub,
      "conversation:#{conversation_id}:messages",
      message
    )
  end

  def list_messages(conversation_id) do
    from(m in Message,
      where: m.conversation_id == ^conversation_id,
      order_by: [asc: m.inserted_at],
      preload: :user
    )
    |> Repo.all()
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(scope, 123)
      %Message{}

      iex> get_message!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(%Scope{} = scope, id) do
    Repo.get_by!(Message, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(scope, %{field: value})
      {:ok, %Message{}}

      iex> create_message(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  # def create_message(%Scope{} = scope, attrs) do
  #   with {:ok, message} <-
  #          %Message{}
  #          |> Message.changeset(attrs, scope)
  #          |> Repo.insert() do
  #     message = Repo.preload(message, :user)

  #     conversation_id = message.conversation_id

  #     Repo.get!(Conversations, conversation_id)
  #     |> Ecto.Changeset.change(last_message_at: message.inserted_at)
  #     |> Repo.update()

  #     broadcast_message(conversation_id, {:created, message})
  #     {:ok, message}
  #   end
  # end

  # def create_message(%Scope{} = scope, attrs) do
  #   with {:ok, message} <-
  #          %Message{}
  #          |> Message.changeset(attrs, scope)
  #          |> Repo.insert() do
  #     message = Repo.preload(message, :user)
  #     conversation_id = message.conversation_id

  #     {:ok, conversation} =
  #       Repo.get!(Conversations, conversation_id)
  #       |> Ecto.Changeset.change(last_message_at: message.inserted_at)
  #       |> Repo.update()

  #     conversation =
  #       conversation
  #       |> Repo.preload([
  #         :users,
  #         messages:
  #           from(m in Sendit.Chat.Message,
  #             order_by: [desc: m.inserted_at],
  #             limit: 1,
  #             preload: :user
  #           )
  #       ])

  #     Enum.each(conversation.users, fn user ->
  #       Phoenix.PubSub.broadcast(
  #         Sendit.PubSub,
  #         "user:#{user.id}:conversation",
  #         {:updated, conversation}
  #       )
  #     end)

  #     broadcast_message(conversation_id, {:created, message})
  #     {:ok, message}
  #   end
  # end
  #

  # def create_message(%Scope{} = scope, attrs) do
  #   with {:ok, message} <-
  #          %Message{}
  #          |> Message.changeset(attrs, scope)
  #          |> Repo.insert() do
  #     message = Repo.preload(message, :user)
  #     conversation_id = message.conversation_id

  #     {:ok, conversation} =
  #       Repo.get!(Conversations, conversation_id)
  #       |> Ecto.Changeset.change(last_message_at: message.inserted_at)
  #       |> Repo.update()

  #     conversation =
  #       conversation
  #       |> Repo.preload([
  #         :users,
  #         messages:
  #           from(m in Sendit.Chat.Message,
  #             order_by: [desc: m.inserted_at],
  #             limit: 1,
  #             preload: :user
  #           )
  #       ])

  #     count =
  #       Repo.aggregate(from(m in Message, where: m.conversation_id == ^conversation_id), :count)

  #     conversation = %{conversation | messages_count: count}

  #     Enum.each(conversation.users, fn user ->
  #       Phoenix.PubSub.broadcast(
  #         Sendit.PubSub,
  #         "user:#{user.id}:conversation",
  #         {:updated, conversation}
  #       )
  #     end)

  #     broadcast_message(conversation_id, {:created, message})
  #     {:ok, message}
  #   end
  # end

  def create_message(%Scope{} = scope, attrs) do
    with {:ok, message} <-
           %Message{}
           |> Message.changeset(attrs, scope)
           |> Repo.insert() do
      message = Repo.preload(message, :user)
      conversation_id = message.conversation_id

      {:ok, conversation} =
        Repo.get!(Conversations, conversation_id)
        |> Ecto.Changeset.change(last_message_at: message.inserted_at)
        |> Repo.update()

      conversation =
        conversation
        |> Repo.preload([
          :users,
          messages:
            from(m in Sendit.Chat.Message,
              order_by: [desc: m.inserted_at],
              limit: 1,
              preload: :user
            )
        ])

      # broadcast per-user with their own unread count
      Enum.each(conversation.users, fn user ->
        unread =
          from(m in Sendit.Chat.Message,
            left_join: r in Sendit.Chat.ConversationRead,
            on: r.conversation_id == m.conversation_id and r.user_id == ^user.id,
            where: m.conversation_id == ^conversation_id,
            where: is_nil(r.last_read_at) or m.inserted_at > r.last_read_at,
            select: count(m.id)
          )
          |> Repo.one()

        Phoenix.PubSub.broadcast(
          Sendit.PubSub,
          "user:#{user.id}:conversation",
          {:updated, %{conversation | messages_count: unread}}
        )
      end)

      broadcast_message(conversation_id, {:created, message})
      {:ok, message}
    end
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(scope, message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(scope, message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Scope{} = scope, %Message{} = message, attrs) do
    true = message.user_id == scope.user.id

    with {:ok, message} <-
           message
           |> Message.changeset(attrs, scope)
           |> Repo.update() do
      message = Repo.preload(message, :user)
      broadcast_message(message.conversation_id, {:updated, message})
      {:ok, message}
    end
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(scope, message)
      {:ok, %Message{}}

      iex> delete_message(scope, message)
      {:error, %Ecto.Changeset{}}

  """

  def delete_message(%Scope{} = scope, %Message{} = message) do
    if message.user_id != scope.user.id do
      {:error, :unauthorized}
    else
      with {:ok, message} <- Repo.delete(message) do
        broadcast_message(message.conversation_id, {:deleted, message})
        {:ok, message}
      end
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(scope, message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Scope{} = scope, %Message{} = message, attrs \\ %{}) do
    true = message.user_id == scope.user.id

    Message.changeset(message, attrs, scope)
  end

  def mark_as_read(%Scope{} = scope, conversation_id) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    %ConversationRead{}
    |> ConversationRead.changeset(
      %{
        conversation_id: conversation_id,
        user_id: scope.user.id,
        last_read_at: now
      },
      scope
    )
    |> Repo.insert(
      on_conflict: [set: [last_read_at: now, updated_at: now]],
      conflict_target: [:conversation_id, :user_id]
    )

    conversation =
      Repo.get!(Conversations, conversation_id)
      |> Repo.preload([
        :users,
        messages:
          from(m in Sendit.Chat.Message,
            order_by: [desc: m.inserted_at],
            limit: 1,
            preload: :user
          )
      ])

    conversation = %{conversation | messages_count: 0}

    Phoenix.PubSub.broadcast(
      Sendit.PubSub,
      "user:#{scope.user.id}:conversation",
      {:updated, conversation}
    )

    :ok
  end

  def get_read_timestamps(conversation_id) do
    from(r in ConversationRead,
      where: r.conversation_id == ^conversation_id,
      select: {r.user_id, r.last_read_at}
    )
    |> Repo.all()
    |> Map.new()
  end
end
