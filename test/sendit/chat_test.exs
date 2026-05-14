defmodule Sendit.ChatTest do
  use Sendit.DataCase

  alias Sendit.Chat

  describe "conversation" do
    alias Sendit.Chat.Conversations

    import Sendit.AccountsFixtures, only: [user_scope_fixture: 0]
    import Sendit.ChatFixtures

    @invalid_attrs %{last_message_at: nil}

    test "list_conversation/1 returns all scoped conversation" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      conversations = conversations_fixture(scope)
      other_conversations = conversations_fixture(other_scope)
      assert Chat.list_conversation(scope) == [conversations]
      assert Chat.list_conversation(other_scope) == [other_conversations]
    end

    test "get_conversations!/2 returns the conversations with given id" do
      scope = user_scope_fixture()
      conversations = conversations_fixture(scope)
      other_scope = user_scope_fixture()
      assert Chat.get_conversations!(scope, conversations.id) == conversations
      assert_raise Ecto.NoResultsError, fn -> Chat.get_conversations!(other_scope, conversations.id) end
    end

    test "create_conversations/2 with valid data creates a conversations" do
      valid_attrs = %{last_message_at: ~U[2026-05-13 10:22:00Z]}
      scope = user_scope_fixture()

      assert {:ok, %Conversations{} = conversations} = Chat.create_conversations(scope, valid_attrs)
      assert conversations.last_message_at == ~U[2026-05-13 10:22:00Z]
      assert conversations.user_id == scope.user.id
    end

    test "create_conversations/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.create_conversations(scope, @invalid_attrs)
    end

    test "update_conversations/3 with valid data updates the conversations" do
      scope = user_scope_fixture()
      conversations = conversations_fixture(scope)
      update_attrs = %{last_message_at: ~U[2026-05-14 10:22:00Z]}

      assert {:ok, %Conversations{} = conversations} = Chat.update_conversations(scope, conversations, update_attrs)
      assert conversations.last_message_at == ~U[2026-05-14 10:22:00Z]
    end

    test "update_conversations/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      conversations = conversations_fixture(scope)

      assert_raise MatchError, fn ->
        Chat.update_conversations(other_scope, conversations, %{})
      end
    end

    test "update_conversations/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      conversations = conversations_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Chat.update_conversations(scope, conversations, @invalid_attrs)
      assert conversations == Chat.get_conversations!(scope, conversations.id)
    end

    test "delete_conversations/2 deletes the conversations" do
      scope = user_scope_fixture()
      conversations = conversations_fixture(scope)
      assert {:ok, %Conversations{}} = Chat.delete_conversations(scope, conversations)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_conversations!(scope, conversations.id) end
    end

    test "delete_conversations/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      conversations = conversations_fixture(scope)
      assert_raise MatchError, fn -> Chat.delete_conversations(other_scope, conversations) end
    end

    test "change_conversations/2 returns a conversations changeset" do
      scope = user_scope_fixture()
      conversations = conversations_fixture(scope)
      assert %Ecto.Changeset{} = Chat.change_conversations(scope, conversations)
    end
  end
end
