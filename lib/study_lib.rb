module StudyLib
 
  UseKapcha = true
  KapchaWPM = 300
  UseKapchaNavProtect = true
   
  StudyList = %w(
    framing_beer
    priming_dilemma
    sunk_cost_theater
  )
  
  def framing_beer_text
    return "
      You are lying on the beach on a hot day. All you have to drink is ice water. 
      For the last hour you have been thinking about how much you would enjoy a 
      nice cold bottle of your favorite brand of beer.<br/>
      <br/>
      A companion gets up to 
      go make a phone call and offers to bring back a beer from the only
      nearby place where beer is sold, 
      #{self.task.treatment? ? 'a fancy resort hotel' : 'a small, run-down grocery store'}.<br/>
      <br/>
      He says that the beer might be 
      expensive and so asks how much you are willing to pay for the beer. He says 
      that he will buy the beer if it costs as much or less than the price you 
      state. But if it costs more than the price you state he will not buy it.<br/>
      <br/> 
      You trust your friend, and there is no possibility of bargaining 
      with 
      #{self.task.treatment? ? 'the bartender' : 'store owner'}.
      What price do you tell him?"
  end
  
  def priming_dilemma_question
    return "
      You have just been randomly paired with another Turker. He or she
      is seeing the same thing you are right now and you can choose to 
      cooperate with each other or not to cooperate. If <i>both</i> of you 
      choose to cooperate, you will both be awarded a bonus of 10 cents.<br/>
      <br/>
      However, if you choose to cooperate and the other person <i>doesn't</i>, you make a
      bonus of 20 cents and the other person gets nothing.<br/>
      <br/>
      If you <i>both</i> choose to <i>not</i> cooperate with each other at the same time, you both 
      will get 4 cents as a bonus.<br/>
      <br/>
      Would you like to cooperate with this other person?"    
  end
  
  #see http://www.biblegateway.com/passage/?search=Mark+10%3A17-23&version=NIV
  def priming_dilemma_religious_prime
    return %Q|
      As Jesus started on his way, a man ran up to him and fell on 
      his knees before him. "Good teacher," he asked, "what must I do 
      to inherit eternal life?"<br/>
      <br/>
      "Why do you call me good?" Jesus answered. "No one is good-except 
      God alone. You know the commandments: "You shall not murder, 
      you shall not commit adultery, you shall not steal, you shall 
      not give false testimony, you shall not defraud, honor your 
      father and mother."<br/>
      <br/>
      "Teacher," he declared, "all these I have kept since I was a boy."<br/>
      <br/>
      Jesus looked at him and loved him. "One thing you lack," he said. "Go, 
      sell everything you have and give to the poor, and you will have 
      treasure in heaven. Then come, follow me."<br/>
      <br/>
      At this the man's face fell. He went away sad, because he had great wealth.<br/>
      <br/>
      Jesus looked around and said to his disciples, "How hard it is for the 
      rich to enter the kingdom of God!"<br/>
    |
  end
  
  #excerpt from http://en.wikipedia.org/wiki/Fish#Exotic_species cf Horton et al
  def priming_dilemma_non_religious_prime
    return %Q|
      Some species of fish are viviparous. In such species the mother retains the 
      eggs and nourishes the embryos. Typically, viviparous fish have a strucure 
      analogous to the placenta seen in mammals connecting the mother's blood supply 
      with that of the embryo.<br/>
      <br/>
      Examples of viviparous fish include the surf-perches, 
      spltfins, and lemon shark. Some viviparous fish exhibit oophagy, in which 
      the developing embryos eat other eggs produced by the mother. This has been 
      observed primarily among sharks, such as the shortfin mako and porbeagle, but 
      is known for a few bony fish as well, such as the halfbeak Nomorhamphus 
      ebrardtii.<br/>
      <br/>
      Intrauterine canniblism is an even more unusual mode of vivipary, 
      in which the largest embryos eat weaker and smaller siblings. This behavior 
      is also most commonly found among sharks, such as the grey nurse shark, but has 
      also been reported for Nomorhamphus ebrardtii.<br/>
      <br/>
      Aquarists commonly refer to 
      ovoviviparous and viviparous fish as livebearers although they are known by 
      other colloquial names as well.      
    |    
  end
  
  def sunk_cost_theater_text
    return %Q|
      #{self.task.treatment? ? 'You paid handsomely for tickets' : 'Your friend gave you tickets for free'}
      for a theater production that received rave reviews. You've been wanting
      to see this show for quite some time and it only plays once in your city.
      <br/>
      <br/>
      However, during the night of the show, the weather turned for the worst.
      There's heavy rain and some hail. Your city's mayor is not recommending 
      anyone drive on the roads. Despite the inclement weather, the show is still going to be performed.
      <br/>
      <br/>
      How likely are you to go? 0 means "you're not going" and 9 means "you're definitely going"
      while 5 would mean that "you're unsure about going."
      <br/>
      |
  end
  
end