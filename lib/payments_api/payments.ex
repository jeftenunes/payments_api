defmodule PaymentsApi.Payments do
  alias PaymentsApi.Repo
  alias EctoShorts.Actions
  alias PaymentsApi.Payments.Transaction
  alias PaymentsApi.{Accounts, Currencies}

  def send_money(%{} = attrs) do
    source_id = String.to_integer(attrs.source)
    recipient_id = String.to_integer(attrs.recipient)

    # validate source balance
    # create transactions

    case {Accounts.get_wallet_by(%{id: source_id}), Accounts.get_wallet_by(%{id: recipient_id})} do
      {{:ok, source}, {:ok, recipient}} ->
        # VALIDAR O SALDO ANTES DE TRANSFERIR
        IO.inspect(Accounts.calculate_balance_for_wallet(source.id))

        %{exchange_rate: exchange_rate} =
          retrieve_rate_for_currency(source.currency, recipient.currency)

        transaction_amount = String.to_integer(attrs.amount)

        debit_transaction =
          build_transaction(%{
            type: "DEBIT",
            exchange_rate: 1,
            status: "PROCESSED",
            wallet_id: source.id,
            amount: transaction_amount,
            description: attrs.description
          })

        credit_transaction =
          build_transaction(%{
            type: "CREDIT",
            status: "PROCESSED",
            wallet_id: recipient.id,
            amount: transaction_amount,
            exchange_rate: exchange_rate,
            description: attrs.description
          })

        op_result =
          {:ok, _credit_transaction} =
          Repo.transaction(fn ->
            _debit_transaction_op = Actions.create(Transaction, debit_transaction)
            {:ok, credit_transaction} = Actions.create(Transaction, credit_transaction)

            %{
              id: credit_transaction.id,
              exchange_rate: exchange_rate,
              description: credit_transaction.description,
              amount: transaction_amount * exchange_rate / 100,
              from_currency: source.currency,
              to_currency: recipient.currency
            }
          end)

        Accounts.publish_user_total_worth_updates(source.user_id)
        Accounts.publish_user_total_worth_updates(recipient.user_id)
        op_result

      {{:error, message}, _} ->
        {:error, "source: #{message}"}

      {_, {:error, message}} ->
        {:error, "recipient: #{message}"}
    end
  end

  defp build_transaction(%{} = params) do
    %{
      type: params.type,
      amount: params.amount,
      status: params.status,
      wallet_id: params.wallet_id,
      description: params.description,
      exchange_rate: params.exchange_rate
    }
  end

  defdelegate retrieve_rate_for_currency(from_currency, to_currency), to: Currencies
end
