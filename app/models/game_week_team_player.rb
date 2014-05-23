# -*- encoding : utf-8 -*-
class GameWeekTeamPlayer < ActiveRecord::Base
  def self.find_unique_with(game_week_team, match_player)
    gwtps = GameWeekTeamPlayer.where(game_week_team: game_week_team, match_player: match_player)

    no_of_gwtps = gwtps.size
    if no_of_gwtps == 0
      fail ActiveRecord::RecordNotFound, "Didn't find a record with game_week_team_id '#{game_week_team.id}' and match_player_id '#{match_player.id}'"
    elsif no_of_gwtps > 1
      fail IllegalStateError, "Found #{no_of_gwtps} game week team players with game_week_team_id '#{game_week_team.id}' and match_player_id '#{match_player.id}'"
    end

    gwtps.first
  end

  belongs_to :game_week_team
  belongs_to :match_player

  validates :game_week_team,
            presence: true

  validates :match_player,
            presence: true,
            uniqueness: { scope: :game_week_team, if: :both_are_present }

  validate :both_have_same_gameweek

  def both_are_present
    game_week_team.present? && match_player.present?
  end

  def both_have_same_gameweek
    return unless game_week_team.present?
    return unless match_player.present?

    mp_gw = match_player.game_week
    gwt_gw = game_week_team.game_week

    if gwt_gw.number != mp_gw.number
      errors.add(
        :base,
        'Game Weeks do not match!'
      )
    end
  end
end
