module Utility
  extend self

  def sum_of_all_desired_variants(arr)
    arr.inject(:+)
  end

  def method_name(variants, limit)
    if sum_of_all_desired_variants(variants) <= limit
      # buy all
    elsif find_combinations(variants, limit).empty?
      # buy none
    else
      # COMBS << find_combinations(variants, limit)
    end
  end

  def find_combinations(variants, limit)
    # Decrementing iterator
    variants.size.downto(1) do |i|
      unless variants.combination(i).select {|a| a.reduce(:+) <= limit}.empty?
        return variants.combination(i).select {|a| a.reduce(:+) <= limit}
      end
    end
    return []
  end
end

