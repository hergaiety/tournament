defmodule Tournament do
  @separator_input ";"
  @separator_output " | "
  @team "Team"
  @matches "matches played"
  @win "win"
  @loss "loss"
  @draw "draw"
  @points "points"

  @value_default 0
  @points_win 3
  @points_draw 1
  @points_loss 0

  @pad_team 30
  @pad_value 2

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
    input
    |> Enum.reduce(%{}, fn line, state ->
      [team1, team2, outcome] = parse_input(line)
      team1_tally = Map.get(state, team1, %{mp: @value_default, wins: @value_default, losses: @value_default, draws: @value_default, points: @value_default})
      team2_tally = Map.get(state, team2, %{mp: @value_default, wins: @value_default, losses: @value_default, draws: @value_default, points: @value_default})

      case outcome do
        @win ->
          state
          |> update_tally(team1, update_team_map(team1_tally, @win))
          |> update_tally(team2, update_team_map(team2_tally, @loss))

        @loss ->
          state
          |> update_tally(team1, update_team_map(team1_tally, @loss))
          |> update_tally(team2, update_team_map(team2_tally, @win))

        @draw ->
          state
          |> update_tally(team1, update_team_map(team1_tally, @draw))
          |> update_tally(team2, update_team_map(team2_tally, @draw))
      end
    end)
    |> Enum.sort_by(fn {_key, %{points: points}} -> points end, :desc)
    |> Enum.reduce(headline(), fn {team, tally}, acc ->
      Enum.join([acc, "\n", team_stats_to_formatted_line(team, tally)])
    end)
  end

  defp parse_input(input), do: String.split(input, @separator_input)

  defp headline(), do:
    format_line([@team, acronym(@matches), acronym(@win), acronym(@draw), acronym(@loss), acronym(@points)])

  defp format_line([team | values]), do: [
    String.pad_trailing(team, @pad_team) |
      values |> Enum.map(&(
        String.pad_leading(to_string(&1), @pad_value)
      ))
  ] |> Enum.join(@separator_output)

  defp team_stats_to_formatted_line(team, %{mp: mp, wins: wins, draws: draws, losses: losses, points: points}) do
    format_line([team, mp, wins, draws, losses, points])
  end

  defp update_tally(state, team, tally) do
    Map.put(state, team, tally)
  end

  defp update_team_map(%{wins: wins, points: points, mp: mp} = team, @win) do
    %{team | wins: wins + 1, points: points + @points_win, mp: mp + 1}
  end

  defp update_team_map(%{losses: losses, points: points, mp: mp} = team, @loss) do
    %{team | losses: losses + 1, points: points + @points_loss, mp: mp + 1}
  end

  defp update_team_map(%{draws: draws, points: points, mp: mp} = team, @draw) do
    %{team | draws: draws + 1, points: points + @points_draw, mp: mp + 1}
  end

  defp acronym(string), do:
    string
    |> String.split(" ")
    |> Enum.map(&(String.at(&1, 0)))
    |> Enum.join("")
    |> String.upcase()
end
