defmodule Tournament do
  @doc """
  Given `input` lines representing two teams and whether the first of them won,
  lost, or reached a draw, separated by semicolons, calculate the statistics
  for each team's number of games played, won, drawn, lost, and total points
  for the season, and return a nicely-formatted string table.

  A win earns a team 3 points, a draw earns 1 point, and a loss earns nothing.

  Order the outcome by most total points for the season, and settle ties by
  listing the teams in alphabetical order.
  """
  @spec tally(input :: list(String.t())) :: String.t()
  def tally(input) do
    initial_output = "Team                           | MP |  W |  D |  L |  P"

    input
    |> Enum.reduce(%{}, fn line, state ->
      [team1, team2, outcome] = parse_input(line)
      team1_tally = Map.get(state, team1, %{mp: 0, wins: 0, losses: 0, draws: 0, points: 0})
      team2_tally = Map.get(state, team2, %{mp: 0, wins: 0, losses: 0, draws: 0, points: 0})

      case outcome do
        "win" ->
          state
          |> update_tally(team1, update_team_map(team1_tally, "win"))
          |> update_tally(team2, update_team_map(team2_tally, "loss"))

        "loss" ->
          state
          |> update_tally(team1, update_team_map(team1_tally, "loss"))
          |> update_tally(team2, update_team_map(team2_tally, "win"))

        "draw" ->
          state
          |> update_tally(team1, update_team_map(team1_tally, "draw"))
          |> update_tally(team2, update_team_map(team2_tally, "draw"))
      end
    end)
    |> Enum.to_list()
    |> Enum.sort_by(fn {_key, %{points: points}} -> points end, :desc)
    |> Enum.reduce(initial_output, fn {team, tally}, acc ->
      Enum.join([acc, "\n", team_stats_to_string(team, tally)])
    end)
  end

  defp parse_input(input), do: String.split(input, ";")

  defp team_stats_to_string(team, %{mp: mp, wins: wins, draws: draws, losses: losses, points: points}) do
    [
      String.pad_trailing(team, 30),
      String.pad_leading("#{mp}", 2),
      String.pad_leading("#{wins}", 2),
      String.pad_leading("#{draws}", 2),
      String.pad_leading("#{losses}", 2),
      String.pad_leading("#{points}", 2)
    ]
    |> Enum.join(" | ")
  end

  defp update_tally(state, team, tally) do
    Map.put(state, team, tally)
  end

  defp update_team_map(%{wins: wins, points: points, mp: mp} = team, "win") do
    %{team | wins: wins + 1, points: points + 3, mp: mp + 1}
  end

  defp update_team_map(%{losses: losses, points: points, mp: mp} = team, "loss") do
    %{team | losses: losses + 1, points: points + 0, mp: mp + 1}
  end

  defp update_team_map(%{draws: draws, points: points, mp: mp} = team, "draw") do
    %{team | draws: draws + 1, points: points + 1, mp: mp + 1}
  end
end
