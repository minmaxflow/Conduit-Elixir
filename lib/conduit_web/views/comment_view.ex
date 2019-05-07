defmodule ConduitWeb.CommentView do
  use ConduitWeb, :view

  alias ConduitWeb.CommentView
  alias ConduitWeb.ProfileView

  def render("index.json", %{comments: comments}) do
    %{
      comments: render_many(comments, CommentView, "comment.json")
    }
  end

  def render("show.json", %{comment: comment}) do
    %{
      comment: render_one(comment, CommentView, "comment.json")
    }
  end

  def render("comment.json", %{comment: comment}) do
    %{
      id: comment.id,
      createdAt: DateTime.to_iso8601(comment.created_at),
      updatedAt: DateTime.to_iso8601(comment.updated_at),
      body: comment.body,
      author: render_one(comment.author, ProfileView, "profile.json")
    }
  end
end
