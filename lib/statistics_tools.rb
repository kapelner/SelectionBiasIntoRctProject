module StatisticsTools #we really really need the R bridge to be implemented...

  StdNormalDist = Rubystats::NormalDistribution.new(0, 1)

  AlphaLevel = 0.05

  # TODO: Create description
  def randomly_sample_one(choices, probabilities = nil)
    #handle easy case first
    return choices[(rand * choices.length).floor] if probabilities.nil?

    raise "probabilities array not specified correctly" if probabilities.length != choices.length || probabilities.inject(0){|sum, p| sum + p} != 1
    total_prob = 0
    rand_no = rand
    choices.each_with_index do |c, i|
      total_prob += probabilities[i]
      return c if rand_no < total_prob
    end
    choices.last
  end

  #Find the median of the array in a pseudo pattern match
  def median(arr)
    return nil if arr.nil?
    arr = arr.reject{|e| e.nil?}
    return nil if arr.empty?
    return arr.first if arr.length == 1

    #Sort the array to be in order.
    arr = arr.sort{|a, b| a <=> b}
    l = arr.length

    #If the array has an even number of elements, pull the middle two elements and average them. If not, just find the middle entry.
    l % 2 == 0 ? ((arr[l / 2 - 1] + arr[l / 2]) / 2.to_f) : arr[(l / 2.to_f).floor]
  end

  #Find the mean of the array in a psudo pattern match
  def samp_avg(arr)

    #if arr is nil, return nil. Also return nil if arr is empty after discarding nils.
    return nil if arr.nil?
    arr = arr.reject{|e| e.nil?}
    return nil if arr.empty?

    #Sum up all members of arr and divide it by the length of r. Return a float.
    arr.inject(0){|sum, i| sum + i} / arr.length.to_f
  end

  #sample variance (s^2)
  def samp_var(arr)

    #if arr is nil or has less than a length of 2 after removing all nils, return nil.
    return nil if arr.nil?
    arr = arr.reject{|e| e.nil?}
    return nil if arr.length <= 1

    #Find the mean and then sum the squared differences from the mean.
    x_bar = samp_avg(arr)
    arr.inject(0){|sum, i| sum + ((i - x_bar) ** 2)} / (arr.length - 1).to_f
  end

  def samp_sd(arr)

    #basically, sqrt the variance. Also can be written as
    # var = variance(arr)
    # return nil if var.nil?
    # return var
    return nil if arr.nil?
    arr = arr.reject{|e| e.nil?}
    return nil if arr.length <= 1
    Math.sqrt(samp_var(arr))
  end

  #Welch's t-test assume H_0: \mu_1 - \mu_2 = 0 i.e. no difference in means
  #if std errors ratios are within a certain epsilon, used pooled approach
  VarRatioSameCutoff = 3 #yay Stat 102
  def two_sample_t_test(samp_1, samp_2)
    return nil if samp_1.nil? or samp_2.nil?
    samp_1 = samp_1.reject{|e| e.nil?}
    samp_2 = samp_2.reject{|e| e.nil?}
    return nil if samp_1.length <= 1 or samp_2.length <= 1
    x_bar_diff, ssq_1, ssq_2, n_1, n_2 = diff_variances_ns(samp_1, samp_2)
    pooled_or_unpooled, st_err_diff = if ssq_1 / ssq_2 < VarRatioSameCutoff || ssq_2 / ssq_1 < VarRatioSameCutoff
                    #use pooled
                    ['p', Math.sqrt(((n_1 - 1) * ssq_1 + (n_2 - 1) * ssq_2) / (n_1 + n_2 - 2)) * Math.sqrt(1 / n_1 + 1 / n_2)]
                  else
                    #use unpooled
                    ['u', Math.sqrt(ssq_1 / n_1 + ssq_2 / n_2)]
                  end
    [x_bar_diff / st_err_diff, two_tailed_normal_probability(x_bar_diff / st_err_diff)]
  end

  def two_proportion_z_test_unpooled(r_1, n_1, r_2, n_2)
    return nil if r_1.nil? or n_1.nil? or r_2.nil? or n_2.nil?
    return nil if n_1.zero? or n_2.zero?
    diff, st_err_diff = diff_props_stderr(r_1, n_1, r_2, n_2)
    diff / st_err_diff
  end

  def two_tailed_normal_probability(z)
    return nil if z.nil?
    2 * (1 - StdNormalDist.cdf(z.abs))
  end

  def power_of_unpooled_t_test(samp_1, samp_2)
    return nil if samp_1.nil? or samp_2.nil?
    samp_1 = samp_1.reject{|e| e.nil?}
    samp_2 = samp_2.reject{|e| e.nil?}
    return nil if samp_1.length <= 1 or samp_2.length <= 1
    x_bar_diff, ssq_1, ssq_2, n_1, n_2 = diff_variances_ns(samp_1, samp_2)
    s = Math.sqrt(ssq_1 / n_1 + ssq_2 / n_2) #i.e. the unpooled estimate of std error
    x_bar_star = 0 + StdNormalDist.icdf(1 - AlphaLevel / 2) * s #diff* + z* x s
    alt_hypothesis = Rubystats::NormalDistribution.new(x_bar_diff.abs, s)
    begin
      1 - alt_hypothesis.cdf(x_bar_star || 0)
    rescue
      0
    end
  end

  def power_of_two_prop_z_test(r_1, n_1, r_2, n_2)
    return nil if r_1.nil? or n_1.nil? or r_2.nil? or n_2.nil?
    return nil if n_1.zero? or n_2.zero?
    diff, st_err_diff = diff_props_stderr(r_1, n_1, r_2, n_2)
    diff_star = 0 + StdNormalDist.icdf(1 - AlphaLevel / 2) * st_err_diff #diff* + z* x s
    alt_hypothesis = Rubystats::NormalDistribution.new(diff.abs, st_err_diff)
    begin
      1 - alt_hypothesis.cdf(diff_star || 0)
    rescue
      0
    end
  end

  def diff_variances_ns(samp_1, samp_2)
    [samp_avg(samp_1) - samp_avg(samp_2), samp_var(samp_1), samp_var(samp_2), samp_1.length.to_f, samp_2.length.to_f]
  end

  def diff_props_stderr(r_1, n_1, r_2, n_2)
    prop_1 = r_1 / n_1.to_f
    prop_2 = r_2 / n_2.to_f
    [prop_1 - prop_2, Math.sqrt(prop_1 * (1 - prop_1) / n_1.to_f + prop_2 * (1 - prop_2) / n_2.to_f), prop_1, prop_2]
  end
end