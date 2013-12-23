module ApplicationHelper
  include StatisticsTools
 
  def kapcha_tokenize(text)
    tokenized = text.to_s.split(/\s/).reject{|str| str.blank?}.inject([]) do |arr, token|
      if token == "<br/>"
        arr << "<br/>"
      else
        arr << %Q|<span class="kapcha_token" style="display:none;">#{token}</span>|  
      end      
      arr
    end
    raw(tokenized.join(' '))
   end  
end
