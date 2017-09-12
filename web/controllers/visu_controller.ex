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

  def pie(conn, _params) do
    transactions = Repo.all( from t in Monedge.Transaction,
      join: c in assoc(t, :category),
      group_by: c.name,
      select: [c.name, sum(t.amount)]  )

    sorted = filterNonOutFlows(transactions)

    Logger.info ("sorted: #{inspect(sorted)}")

    render(conn, "pie.html",transactions: sorted)
  end

  def barWithDate(conn, params) do
    date_range = %{range_start: ~D[2017-01-01], range_end: ~D[2017-03-31]}
    render(conn, "bar_with_date.html",date_range: date_range)
  end

  def sbarWithDate(conn, params) do
    date_range = %{range_start: ~D[2017-01-01], range_end: ~D[2017-03-31]}
    render(conn, "sbar_with_date.html",date_range: date_range)
  end

  def viewBarByCategoryAndDateRange(conn, params) do
    range_start= conn.params["date_range"]["range_start"]
    range_end= conn.params["date_range"]["range_end"]

    sorted = groupByCategory(range_start, range_end)

    Logger.info ("sorted: #{inspect(sorted)}")

    render(conn, "d3testbar.html",transactions: sorted, range_start: range_start, range_end: range_end)
  end

  def viewStackedBarByCategoryAndDateRange(conn, params) do
    range_start= conn.params["date_range"]["range_start"]
    range_end= conn.params["date_range"]["range_end"]

    data = groupByMonthAndCategory(range_start, range_end)

    sorted = data
                |> Map.values 
                |> Enum.into([], fn (a) -> Enum.map(a,fn(b) -> %{Enum.at(b,0) => Enum.at(b,3)} end)end)
                |> Enum.map(fn(a)-> Enum.reduce(a,fn (x, acc) -> Map.merge(x, acc, fn(_key, map1, map2) -> for {k, v1} <- map1, into: %{}, do: {k, v1 + map2[k]} end ) end) end)
    
    totals = sorted 
              |> Enum.map(fn(a) -> Enum.reduce(a,0, fn({_k,v},acc) -> acc+ v end)end)

    withTotal = Enum.zip(sorted, totals) 
              |> Enum.map(fn(a) -> Map.merge(elem(a,0), %{"total" => elem(a,1)}) end)

    result = Enum.zip(withTotal, Map.keys(data))
              |> Enum.map(fn(a) -> Map.merge(elem(a,0), %{"month" => elem(a,1)}) end)

    Logger.info ("result: #{inspect(result)}")

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
      group_by: [c.name, fragment("date_part('month', ?)", t.date),fragment("date_part('year', ?)", t.date)],
      select: [c.name, fragment("date_part('month', ?)", t.date),fragment("date_part('year', ?)", t.date), sum(t.amount)]  )

    sorted = Enum.filter(transactions, &(Enum.at(&1,3) <0))
    |> Enum.filter(&(Enum.at(&1,0)  != "Transfer"))
    |> Enum.filter(&(Enum.at(&1,0)  != "Credit card"))
    
    categories = MapSet.new(sorted, fn(t) -> Enum.at(t,0) end)
    months = MapSet.new(sorted, fn(t) -> "#{Enum.at(t,2)}-#{Enum.at(t,1)}" end)
    byMonth = Enum.group_by(sorted, fn(x)-> "#{Enum.at(x,2)}-#{Enum.at(x,1)}" end)
    Logger.info ("byMonth: #{inspect(byMonth)}")
    byMonth

  end

  def filterNonOutFlows(transactions) do
    sorted = Enum.filter(transactions, &(Enum.at(&1,1) <0))
    |> Enum.filter(&(Enum.at(&1,0)  != "Transfer"))
    |> Enum.filter(&(Enum.at(&1,0)  != "Credit card"))
    |>Enum.sort(&(Enum.at(&1,1) <= Enum.at(&2,1)))
  end
end
