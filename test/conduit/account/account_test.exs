defmodule Conduit.AccountTest do
  use Conduit.DataCase

  alias Ecto.Changeset

  alias Conduit.Account
  alias Conduit.Account.{User}

  @valid_attr %{email: "test@test.com", username: "username", password: "password123"}
  @invalid_atts %{email: "test@test.com", username: "abcd"}

  describe "user register" do
    test "create_user/1 create valid user" do
      assert {:ok, %User{} = user} = Account.create_user(@valid_attr)
      assert user.email == @valid_attr.email
      assert user.username == @valid_attr.username
    end

    test "create_user/1 create invalid user" do
      assert {:error, %Changeset{}} = Account.create_user(@invalid_atts)
    end

    test "create_user/1 create invalid user(2)" do
      attrs = %{@invalid_atts | username: "ab"}
      assert {:error, %Changeset{} = changset} = Account.create_user(attrs)
      assert %{username: _, password: _} = errors_on(changset)
    end

    test "create_user/1 check unique constraint" do
      Account.create_user(@valid_attr)

      assert {:error, %Changeset{} = changeset} = Account.create_user(@valid_attr)
      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "user auth" do
    test "login success" do
      Account.create_user(@valid_attr)
      assert {:ok, _} = Account.authenticate_user(@valid_attr.email, @valid_attr.password)
    end

    test "login fail" do
      Account.create_user(@valid_attr)

      assert {:error, :unauthorized} =
               Account.authenticate_user(@valid_attr.email, "wrong pass word")
    end
  end

  describe "user follow" do
    test "follow" do
      user1 = %{email: "user1@test.com", username: "usr1", password: "user1pass"}
      user2 = %{email: "user2@test.com", username: "usr2", password: "user2pass"}

      assert {:ok, user1} = Account.create_user(user1)
      assert {:ok, user2} = Account.create_user(user2)

      assert {:ok, _} = Account.follow_user(user1, user2.username)
      assert {:ok, _} = Account.follow_user(user2, user1.username)
    end

    test "unfollow" do
      user1 = %{email: "user1@test.com", username: "usr1", password: "user1pass"}
      user2 = %{email: "user2@test.com", username: "usr2", password: "user2pass"}

      assert {:ok, user1} = Account.create_user(user1)
      assert {:ok, user2} = Account.create_user(user2)

      assert {:error, :not_found} = Account.unfollow_user(user1, user2.username)
      assert {:error, :not_found} = Account.unfollow_user(user2, user1.username)

      Account.follow_user(user1, user2.username)
      Account.follow_user(user2, user1.username)

      assert {:ok, _} = Account.unfollow_user(user1, user2.username)
      assert {:ok, _} = Account.unfollow_user(user2, user1.username)
    end
  end
end
