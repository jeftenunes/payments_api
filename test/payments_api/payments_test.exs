defmodule PaymentsApi.PaymentsTest do
  use PaymentsApi.DataCase

  alias PaymentsApi.Payments

  describe "wallets" do
    alias PaymentsApi.Payments.Wallet

    import PaymentsApi.PaymentsFixtures

    @invalid_attrs %{balance: nil, currency: nil}

    test "list_wallets/0 returns all wallets" do
      wallet = wallet_fixture()
      assert Payments.list_wallets() == [wallet]
    end

    test "get_wallet!/1 returns the wallet with given id" do
      wallet = wallet_fixture()
      assert Payments.get_wallet!(wallet.id) == wallet
    end

    test "create_wallet/1 with valid data creates a wallet" do
      valid_attrs = %{balance: 42, currency: "some currency"}

      assert {:ok, %Wallet{} = wallet} = Payments.create_wallet(valid_attrs)
      assert wallet.balance == 42
      assert wallet.currency == "some currency"
    end

    test "create_wallet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_wallet(@invalid_attrs)
    end

    test "update_wallet/2 with valid data updates the wallet" do
      wallet = wallet_fixture()
      update_attrs = %{balance: 43, currency: "some updated currency"}

      assert {:ok, %Wallet{} = wallet} = Payments.update_wallet(wallet, update_attrs)
      assert wallet.balance == 43
      assert wallet.currency == "some updated currency"
    end

    test "update_wallet/2 with invalid data returns error changeset" do
      wallet = wallet_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_wallet(wallet, @invalid_attrs)
      assert wallet == Payments.get_wallet!(wallet.id)
    end

    test "delete_wallet/1 deletes the wallet" do
      wallet = wallet_fixture()
      assert {:ok, %Wallet{}} = Payments.delete_wallet(wallet)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_wallet!(wallet.id) end
    end

    test "change_wallet/1 returns a wallet changeset" do
      wallet = wallet_fixture()
      assert %Ecto.Changeset{} = Payments.change_wallet(wallet)
    end
  end

  describe "transactions" do
    alias PaymentsApi.Payments.Transaction

    import PaymentsApi.PaymentsFixtures

    @invalid_attrs %{status: nil, description: nil, amount: nil}

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Payments.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Payments.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      valid_attrs = %{status: "some status", description: "some description", amount: 42}

      assert {:ok, %Transaction{} = transaction} = Payments.create_transaction(valid_attrs)
      assert transaction.status == "some status"
      assert transaction.description == "some description"
      assert transaction.amount == 42
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()

      update_attrs = %{
        status: "some updated status",
        description: "some updated description",
        amount: 43
      }

      assert {:ok, %Transaction{} = transaction} =
               Payments.update_transaction(transaction, update_attrs)

      assert transaction.status == "some updated status"
      assert transaction.description == "some updated description"
      assert transaction.amount == 43
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_transaction(transaction, @invalid_attrs)

      assert transaction == Payments.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Payments.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Payments.change_transaction(transaction)
    end
  end
end
