class Demographic < ActiveRecord::Base
  include DemographicTest
  
  
  attr_accessible :mturk_worker_id,
    :age,
    :gender,
    :urban_rural,
    :highest_education,
    :marital_status,
    :employment_status,
    :num_children,
    :income,
    :religion,
    :belief_in_divine,
    :race,
    :participate_in_study,
    :born_here,
    :english_first_language,
    :nfc_1,
    :nfc_2,
    :big_5_1,
    :big_5_2,
    :big_5_3,
    :big_5_4,
    :big_5_5

end
