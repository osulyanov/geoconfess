class Parish < ActiveRecord::Base
  has_many :users

  validates :name, presence: true
  validates :email, presence: true
end

# == Schema Information
#
# Table name: parishes
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
