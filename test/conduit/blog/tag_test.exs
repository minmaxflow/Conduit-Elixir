defmodule Conduit.Blog.TagTest do
  use Conduit.DataCase

  alias Conduit.Blog
  alias Conduit.Blog.{Tag}

  test "tag" do
    assert [] = Blog.list_tags()

    {:ok, %Tag{name: "tag", id: id}} = Blog.create_tag("tag")
    {:ok, %Tag{name: "tag", id: ^id}} = Blog.create_tag("tag")

    assert [%Tag{id: ^id}] = Blog.list_tags()

    assert {:ok, [%{name: "tag", id: ^id} | _]} = Blog.create_taglist(["tag", "tag2", "tag3"])
  end
end
