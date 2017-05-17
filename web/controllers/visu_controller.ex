defmodule Monedge.VisuController do
  require Logger
  use Monedge.Web, :controller

  alias Monedge.Transaction
  alias Monedge.Category

  def d3test(conn, _params) do
    transactions = Repo.all( from t in Monedge.Transaction,
    join: c in assoc(t, :category),
    # where: t.category_id in [1,2,3,4,5,6,7,8,9],
    group_by: c.name,
    select: [c.name, sum(t.amount)]  )

    sorted = Enum.filter(transactions, &(Enum.at(&1,1) <0))
            |> Enum.filter(&(Enum.at(&1,0)  != "Transfer"))
            |> Enum.filter(&(Enum.at(&1,0)  != "Credit card"))
            |>Enum.sort(&(Enum.at(&1,1) <= Enum.at(&2,1)))
            |>Enum.take(10)

    Logger.info ("sorted: #{inspect(sorted)}")

    render(conn, "d3testbar.html",transactions: sorted)
  end
  
end
