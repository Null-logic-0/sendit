defmodule Sendit.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sendit.Chat` context.
  """

  # def conversations_fixture(scope, attrs \\ %{}) do
  #   attrs =
  #     Enum.into(attrs, %{
  #       last_message_at: ~U[2026-05-13 10:22:00Z]
  #     })

  #   {:ok, conversations} = Sendit.Chat.create_conversations(scope, attrs)
  #   conversations
  # end

  @doc """
  Generate a message.
  """
  def message_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        body: "some body"
      })

    {:ok, message} = Sendit.Chat.create_message(scope, attrs)
    message
  end
end
