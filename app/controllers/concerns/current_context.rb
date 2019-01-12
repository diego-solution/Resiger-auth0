# frozen_string_literal: true

# manages current context/team when using the API
module CurrentContext
  extend ActiveSupport::Concern

  # returns current team for logged in user
  def current_team
    if params[:team_id].nil? || params[:team_id] == 'default' || params[:team_id] == 'undefined'
      return current_user.teams.first
    end
    if current_user.super_admin
      Team.find_by(id: params[:team_id])
    else
      current_user.teams.find_by(id: params[:team_id])
    end
  end
end
