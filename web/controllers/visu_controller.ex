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

    sorted = groupByMonthAndCategory(range_start, range_end)
    sorted = [      %{:month => 1, :clothing =>700, :energy => 100},      
                    %{:month => 2, :clothing =>200, :energy => 100}    ]
  #     ["Clothing", 1.0, -88.82], ["Sport", 1.0, -100.82], ["Going out", 1.0, -10.0],
  #   ["Home improvements", 1.0, -870.51], ["Dry cleaning", 1.0, -56.5],
  #   ["Books", 1.0, -191.08999999999997], ["Energy", 1.0, -153.0],
  #   ["Insurance", 1.0, -67.92], ["Restaurant", 1.0, -345.98],
  #   ["Video games", 1.0, -34.28], ["Cash", 1.0, -201.85],
  #   ["Fast food", 1.0, -124.75], ["Groceries", 1.0, -55.84],
  #   ["Telecom", 1.0, -15.0], ["Music", 1.0, -14.99], ["Travel", 1.0, -275.39],
  #  ["Travel", 2.0, -244.95], ["Fast food", 2.0, -126.03],
  #   ["Groceries", 2.0, -162.36], ["Music", 2.0, -14.99], ["Telecom", 2.0, -15.0],
  #   ["Gambling", 2.0, -50.0], ["Cash", 2.0, -200.0], ["Restaurant", 2.0, -287.89],
  #   ["Books", 2.0, -65.71], ["Energy", 2.0, -153.0], ["Dry cleaning", 2.0, -56.0],
  #   ["Video games", 2.0, -8.95], ["Home improvements", 2.0, -53.09],
  #   ["Going out", 2.0, -177.17999999999998]]
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

    sorted = Enum.filter(transactions, &(Enum.at(&1,2) <0))
    |> Enum.filter(&(Enum.at(&1,0)  != "Transfer"))
    |> Enum.filter(&(Enum.at(&1,0)  != "Credit card"))
    
    categories = MapSet.new(sorted, fn(t) -> Enum.at(t,0) end)
    months = MapSet.new(sorted, fn(t) -> Enum.at(t,1) end)
    byMonth = Enum.group_by(sorted, fn(x)-> Enum.at(x,1) end)
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
