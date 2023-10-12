defmodule PaymentsApiWeb.Resolvers.ErrorsHelper do
  def traverse_errors(changeset) do
    Enum.map(changeset.errors, &(&1 |> elem(1) |> elem(0)))
  end

  def build_graphql_error(messages) when is_list(messages) do
    {:error, messages}
  end
end
