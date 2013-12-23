class BigBrotherParam < ActiveRecord::Base
  belongs_to :big_brother_track
  
  attr_accessible :param, :value, :big_brother_track
end
