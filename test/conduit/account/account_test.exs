defmodule Conduit.AccountTest do
  use Conduit.DataCase

  alias Ecto.Changeset

  alias Conduit.Account
  alias Conduit.Account.{User}

  @valid_attr %{email: "test@test.com", username: "username", password: "password123"}
  @invalid_atts %{}

  test "create_user/1 create valid user" do
    assert {:ok, %User{} = user} = Account.create_user(@valid_attr)
    assert user.email == @valid_attr.email
    assert user.username == @valid_attr.username
  end

  test "create_user/1 create invalid user" do
    assert {:error, %Changeset{} = _} = Account.create_user(@invalid_atts)
  end

  test "create_user/1 check unique constraint" do
    Account.create_user(@valid_attr)

    assert {:error, %Changeset{} = _} = Account.create_user(@valid_attr)
  end
end
