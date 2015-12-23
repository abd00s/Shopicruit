module Utility
  extend self

  def weight_of_variants(arr)
    arr.inject(1){ |sum, variant| sum + variant.grams }
  end

  def method_name(variants, limit)
    if weight_of_variants(variants) <= limit
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
      unless variants.combination(i).select {|comb| weight_of_variants(comb) <= limit}.empty?
        return variants.combination(i).select {|comb| weight_of_variants(comb) <= limit}
      end
    end
    return []
  end
end

