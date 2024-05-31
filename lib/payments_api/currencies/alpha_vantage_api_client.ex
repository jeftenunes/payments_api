defmodule PaymentsApi.Currencies.AlphaVantageApiClient do
  @qry_param_function "CURRENCY_EXCHANGE_RATE"
  @api_response_root_node "Realtime Currency Exchange Rate"
  @api_key Application.compile_env(:payments_api, :alpha_vantage_api_key)
  @api_url Application.compile_env(:payments_api, :alpha_vantage_api_url)

  def fetch(%{from_currency: _from_currency, to_currency: _to_currency} = query_params) do
    case send_request(query_params) do
      {:ok, response} -> deserialize_http_response(response)
      _ -> {:error, "error retrieving exchange rate"}
    end
  end

  defp deserialize_http_response(%Finch.Response{
         status: 200,
         body: body,
         headers: _headers
       }) do
    raw_response =
      body
      |> Jason.decode!()
      |> Map.get(@api_response_root_node)

    %{
      bid_price: raw_response["8. Bid Price"],
      ask_price: raw_response["9. Ask Price"],
      exchange_rate: String.to_float(raw_response["5. Exchange Rate"]),
      to_currency: raw_response["3. To_Currency Code"],
      last_refreshed: raw_response["6. Last Refreshed"],
      from_currency: raw_response["1. From_Currency Code"]
    }
  end

  defp send_request(query_params) do
    :get
    |> Finch.build(build_encoded_url(query_params))
    |> Finch.request(PaymentsApi.Finch)
  end

  defp build_encoded_url(query) do
    query_params =
      %{"apikey" => @api_key, "function" => @qry_param_function}
      |> Map.merge(query)
      |> URI.encode_query()

    "#{@api_url}?#{query_params}"
  end
end
