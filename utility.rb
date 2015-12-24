module Utility
  extend self

  def weight_of_variants(arr)
    arr.inject(1){ |sum, variant| sum + variant.grams }
  end

  def method_name(variants, limit)
    if weight_of_variants(variants) <= limit
      # buy all
      message = "The total weight of all desired variants is under the weight limit
      you may purchase all."
    elsif find_combinations(variants, limit).empty?
      # buy none
      message = "All variants are too heavy, you can't purchase any."
    else
      # COMBS << find_combinations(variants, limit)
      message = "This selection of variants is the most you can carry while
      remaining under the limit"
    end
  end

  def find_combinations(variants, limit)
    # Decrementing iterator; Start at combination size == number of possible variants
    variants.size.downto(1) do |i|
      # Is there such a combination at this size? (i.e. satisfies weight limit)
      unless variants.combination(i).select {|comb| weight_of_variants(comb) <= limit}.empty?
        return variants.combination(i).select {|comb| weight_of_variants(comb) <= limit}
      end
    end
    # Return an empty array if the limit cannot be satisfied
    # i.e. lightest variant is heavier than the limit
    return []
  end
end

