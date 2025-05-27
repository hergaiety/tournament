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
    |> Stream.map(&parse_input_line_values/1)
    # TODO: Convert to Stream.transform/3
    |> Enum.reduce(%{}, fn [team1, team2, outcome], state ->
      update_tallies(state,
        get_team_tally(state, team1),
        get_team_tally(state, team2),
        outcome
      )
    end)
    |> Enum.sort_by(fn {_key, %{points: points}} -> points end, :desc)
    |> Enum.reduce(headline(), fn {team, tally}, acc ->
      Enum.join([acc, "\n", team_stats_to_formatted_line(team, tally)])
    end)
  end

  defp parse_input_line_values(input), do: String.split(input, @separator_input)

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

  defp get_team_tally(state, team), do: {
    team,
    Map.get(state, team, %{mp: @value_default, wins: @value_default, losses: @value_default, draws: @value_default, points: @value_default})
  }

  defp update_tally(state, team, tally), do: Map.put(state, team, tally)

  # NOTE: A team losing means the other team won, so we rearrange the arguments for a win condition
  defp update_tallies(state, {team1, team1_tally}, {team2, team2_tally}, @loss), do:
    update_tallies(state, {team2, team2_tally}, {team1, team1_tally}, @win)
  defp update_tallies(state, {team1, team1_tally}, {team2, team2_tally}, @win), do:
    state
    |> update_tally(team1, update_team_map(team1_tally, @win))
    |> update_tally(team2, update_team_map(team2_tally, @loss))
  defp update_tallies(state, {team1, team1_tally}, {team2, team2_tally}, _draw), do:
    state
    |> update_tally(team1, update_team_map(team1_tally, @draw))
    |> update_tally(team2, update_team_map(team2_tally, @draw))

  defp update_team_map(%{wins: wins, points: points} = team, @win), do:
    update_team_map(%{team | wins: wins + 1, points: points + @points_win})

  defp update_team_map(%{losses: losses, points: points} = team, @loss), do:
    update_team_map(%{team | losses: losses + 1, points: points + @points_loss})

  defp update_team_map(%{draws: draws, points: points} = team, @draw), do:
    update_team_map(%{team | draws: draws + 1, points: points + @points_draw})

  # NOTE: Always want to call this, any match outcome is a match played
  defp update_team_map(%{mp: mp} = team), do:
    %{team | mp: mp + 1}

  # NOTE: Will need to be more clever if localized
  defp acronym(string), do:
    string
    |> String.split(" ")
    |> Enum.map(&(String.at(&1, 0)))
    |> Enum.join("")
    |> String.upcase()
end
