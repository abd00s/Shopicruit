module Utility
  extend self

  def sum_of_all_desired_variants(arr)
    arr.inject(:+)
  end

  def method_name(variants, limit)
    if sum_of_all_desired_variants(variants) <= limit
      puts "all"
      # buy all
    elsif find_combinations(variants, limit).empty?
      puts "none"
      # buy none
    else
      # COMBS << find_combinations(variants, limit)
      print find_combinations(variants, limit)
    end
  end

  def find_combinations(variants, limit)
    # Decrementing iterator
    variants.size.downto(1) do |i|
      unless variants.combination(i).select {|a| a.reduce(:+) <= limit}.empty?
        return variants.combination(i).select {|a| a.reduce(:+) <= limit}
        # break
      end
      # return []
      # if none, return value is size of range // fix this
    end
  end

  x=[2,4,6,8,10,22]
  method_name(x,10)
end

