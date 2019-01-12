# frozen_string_literal: true
# == Schema Information
#
# Table name: report_schedules
#
#  id         :bigint(8)        not null, primary key
#  team_id    :bigint(8)
#  period     :string
#  start_date :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_report_schedules_on_team_id  (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#

class ReportSchedule < ApplicationRecord
  belongs_to :team
end
