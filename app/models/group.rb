# frozen_string_literal: true
# == Schema Information
#
# Table name: groups
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  team_id    :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_groups_on_team_id  (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#

# groups of events within a specific team
class Group < ApplicationRecord
  belongs_to :team
  has_many :events, dependent: :destroy

  validates :name, presence: true
end
