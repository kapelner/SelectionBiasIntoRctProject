module DemographicTest
  QnA = [
    [:age, {
      :type => :free_response,
      :question => "What is your age? Enter the number of years below.",
    }],
    [:gender, {
      :type => :categorical_random,
      :question => "What is your gender?",
      :answer_choices => [
        ["Male", "M"], ["Female", "F"]
      ]
    }],
    [:urban_rural, {
      :type => :categorical_random,
      :question => "What type of place do you live in?",
      :answer_choices => [
        ["Urban", "U"], ["Rural", "R"]
      ]
    }],
    [:highest_education, {
      :type => :categorical_non_random,
      :question => "What is the highest level of education you have obtained?",
      :answer_choices => [
        ["High school", "HS"], ["Some college", "SC"], ["Bachelor's degree", "BS"], ["Master's degree", "MS"], ["MD / PhD / Doctorate", "DR"]
      ]
    }],
    [:marital_status, {
      :type => :categorical_random,
      :question => "What is your relationship status?",
      :answer_choices => [
        ["Married", "M"], ["Divorced", "D"], ["Single", "S"], ["Widowed", "W"], ["In a relationship", "R"]
      ]
    }],
    [:employment_status, {
      :type => :categorical_random,
      :question => "What is your employment status?",
      :answer_choices => [
        ["Full-time", "FT"], ["Part time", "PT"], ["Unemployed", "UN"], ["Self-employed", "SE"], ["Student", "ST"]
      ]
    }],
    [:num_children, {
      :type => :categorical_non_random,
      :question => "How many children do you have?",
      :answer_choices => [
        ["0", "0"], ["1", "1"], ["2", "2"], ["3", "3"], ["4", "4"], ["5", "5"], ["6", "6"], ["7", "7"], ["8", "8"], ["9", "9"], ["10 or more", "10"]
      ]
    }],
    [:income, {
      :type => :free_response,
      :question => %Q|What is your approximate annual income? Enter a number in *thousands* of dollars (e.g. "30" means $30,000).|,
    }],
    [:religion, {
      :type => :categorical_random,
      :question => "What is your birth religion?",
      :answer_choices => [
        ["Protestant", "PR"], ["Roman Catholic", "RA"], ["Evangelical Christian", "EC"], ["Jewish", "JW"], ["Muslim", "MU"], ["Hindu", "HU"], ["Buddhist", "BU"], ["Other", "OT"], ["None", "NO"]
      ]
    }],
    [:belief_in_divine, {
      :type => :categorical_random,
      :question => "Do you believe in a divine being?",
      :answer_choices => [
        ["Yes", "Y"], ["No", "N"]
      ]
    }],
    [:race, {
      :type => :categorical_random,
      :question => "How would you classify your race?",
      :answer_choices => [
        ["White", "WH"], ["Black", "BL"], ["Hispanic", "HI"], ["Asian / Pacific", "AP"], ["Native American", "NA"], ["Other", "OT"]
      ]
    }],
    [:participate_in_study, {
      :type => :categorical_random,
      :question => "Do you like to participate in academic studies?",
      :answer_choices => [
        ["Yes", "Y"], ["No", "N"]
      ]
    }],
    [:born_here, {
      :type => :categorical_random,
      :question => "Were you born in the United States?",
      :answer_choices => [
        ["Yes", "Y"], ["No", "N"]
      ]
    }],
    [:english_first_language, {
      :type => :categorical_random,
      :question => "Is English your first language?",
      :answer_choices => [
        ["Yes", "Y"], ["No", "N"]
      ]
    }],     
    [:nfc_1, {
      :type => :categorical_random,
      :question => "Do you prefer your life to be filled with puzzles you must solve?",
      :answer_choices => [
        ["Yes", "Y"], ["No", "N"]
      ]
    }],
    [:nfc_2, {
      :type => :categorical_random,
      :question => "It's enough for me that something gets the job done; l I don't care how or why it works.",
      :answer_choices => [
        ["I agree with this statement.", "Y"], ["I don't agree with this statement.", "N"]
      ]
    }],
    [:big_5_1, {
      :type => :categorical_random,
      :question => "I am more...",
      :answer_choices => [
        ["Inventive and curious", "IC"], ["Consistent and cautious", "CC"]
      ]
    }],
    [:big_5_2, {
      :type => :categorical_random,
      :question => "I am more...",
      :answer_choices => [
        ["Efficient and organized", "EO"], ["Easy-going and more careless", "EG"]
      ]
    }],
    [:big_5_3, {
      :type => :categorical_random,
      :question => "I am more...",
      :answer_choices => [
        ["Outgoing and energetic", "OE"], ["Solitary and reserved", "SR"]
      ]
    }],
    [:big_5_4, {
      :type => :categorical_random,
      :question => "I am more...",
      :answer_choices => [
        ["Friendly and compassionate", "FC"], ["Logical and cold", "LC"]
      ]
    }],
    [:big_5_5, {
      :type => :categorical_random,
      :question => "I am more...",
      :answer_choices => [
        ["Sensitive and nervous", "SN"], ["Secure and confident", "SC"]
      ]
    }]
  ]
end