defmodule Monedge.VisuController do
  require Logger
  use Monedge.Web, :controller

  alias Monedge.Transaction
  alias Monedge.Category

  def d3test(conn, _params) do
    transactions = Repo.all( from t in Monedge.Transaction,
    join: c in assoc(t, :category),
    group_by: c.name,
    select: [c.name, sum(t.amount)]  )

    sorted = filterNonOutFlows(transactions)

    Logger.info ("sorted: #{inspect(sorted)}")

    render(conn, "d3testbar.html",transactions: sorted)
  end

  def barWithDate(conn, params) do
    date_range = %{range_start: ~D[2017-01-01], range_end: ~D[2017-03-31]}
    render(conn, "bar_with_date.html",date_range: date_range)
  end

  def view(conn, params) do
    range_start= conn.params["date_range"]["range_start"]
    range_end= conn.params["date_range"]["range_end"]

    sorted = groupByMonthAndCategory(range_start, range_end)

    Logger.info ("sorted: #{inspect(sorted)}")

    render(conn, "d3teststackedbar.html",transactions: sorted, range_start: range_start, range_end: range_end)
  end

  def groupByCategory(range_start, range_end) do
    transactions = Repo.all( from t in Monedge.Transaction,
    join: c in assoc(t, :category),
    where: t.date >= ^range_start,
    where: t.date <= ^range_end,
    group_by: c.name,
    select: [c.name, sum(t.amount)]  )

    sorted = filterNonOutFlows(transactions)
  end


  def groupByMonthAndCategory(range_start, range_end) do
    transactions = Repo.all( from t in Monedge.Transaction,
    join: c in assoc(t, :category),
    where: t.date >= ^range_start,
    where: t.date <= ^range_end,
    group_by: [c.name, fragment("date_part('month', ?)", t.date)],
    select: [c.name, fragment("date_part('month', ?)", t.date), sum(t.amount)]  )

    sorted = sorted = Enum.filter(transactions, &(Enum.at(&1,2) <0))
    |> Enum.filter(&(Enum.at(&1,0)  != "Transfer"))
    |> Enum.filter(&(Enum.at(&1,0)  != "Credit card"))
# [categories]
    categories = MapSet.new(sorted, fn(t) -> Enum.at(t,0) end)
    months = MapSet.new(sorted, fn(t) -> Enum.at(t,1) end)

    byMonth = Enum.group_by(sorted, fn(x)-> Enum.at(x,1) end)
      #Enum.map(months, fn(x) -> %{x, Enum.filter(sorted, &(Enum.at(&1,1)  == x))} end)
    Logger.info ("byMonth: #{inspect(byMonth)}")
# {month val, cat val, total val}
  end

  def filterNonOutFlows(transactions) do
    sorted = Enum.filter(transactions, &(Enum.at(&1,1) <0))
    |> Enum.filter(&(Enum.at(&1,0)  != "Transfer"))
    |> Enum.filter(&(Enum.at(&1,0)  != "Credit card"))
    |>Enum.sort(&(Enum.at(&1,1) <= Enum.at(&2,1)))
  end
end
