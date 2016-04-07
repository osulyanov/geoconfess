class Parish < ActiveRecord::Base
  has_many :users

  validates :name, presence: true
end

# == Schema Information
#
# Table name: parishes
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
