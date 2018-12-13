defmodule ExAwsBehaviour do
  @callback request(ExAws.Operation.Query.t()) :: {:ok, term} | {:error, term}
end

Mox.defmock(ExAwsMock, for: ExAwsBehaviour)
