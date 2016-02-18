require_relative "Api"
require_relative "Product"
require_relative "Variant"

class Shopicruit
  attr_reader :desirable_variants, :limit, :products_to_purchase, :message, :desirable_products, :desired_categories

  def initialize(limit, desired_categories)
    @limit = limit
    @desired_categories = desired_categories
    @desirable_products = []
    @desirable_variants = []
    @products_to_purchase = []
    @message = []
  end

  def self.run(args={})
    limit = args[:limit] || 100
    desired_categories = args[:desired_categories] || ["Computer", "Keyboard"]
    shopicruit = Shopicruit.new(limit, desired_categories)
    shopicruit.filter_products
    shopicruit.find_all_desirable_variants
    shopicruit.find_carriable_combo(shopicruit.desirable_variants, limit)
    puts shopicruit.message
    shopicruit.print_output(shopicruit.products_to_purchase)
  end

  def print_output(products_to_purchase)
    if products_to_purchase.count > 0
      products_to_purchase.each do |product|
        puts "\t#{product.parent.title}"
        puts "\t\t#{product.title}"
      end
      puts "Weighing #{(weight_of_variants(products_to_purchase))} KGs"
      puts "Costing you $#{price_of_variants(products_to_purchase)}"
    end
  end

  def filter_products
    all_products = Api::get_products
    @desirable_products = all_products.select { |product| @desired_categories
      .include?(product["product_type"]) }
    @desirable_products.map! { |product| Product.new(product) }
  end

  def find_all_desirable_variants
    @desirable_products.each do |product|
      product.variants.each do |variant|
        @desirable_variants << Variant.new(variant, product)
      end
    end
  end

  def find_carriable_combo(variants, limit)
    if weight_of_variants(variants) <= limit
      # buy all
      message = "The total weight of all desired variants is under the weight limit you may purchase all."
      update_products_to_purchase(variants, message)
    elsif find_combinations(variants, limit).empty?
      # buy none
      message = "All variants are too heavy, you can't purchase any."
      update_products_to_purchase([], message)
    else
      # buy combination that maximizes weight and minimizes price
      combinations = find_combinations(variants, limit)
      # if there are >1 combs, select the cheaper one
      variants = select_cheapest_combination(combinations)
      message = "This selection of variants is the most you can carry while remaining under the limit"
      update_products_to_purchase(variants, message)
    end
  end

  def weight_of_variants(variants)
    variants.inject(0){ |sum, variant| sum + variant.grams }
  end

  def find_combinations(variants, limit)
    # Decrementing iterator; Start at combination size == number of possible variants
    # so that we purchase them all if their total weight is less than our limit
    variants.size.downto(1) do |i|
      # Is there a combination at this size that satisfies our weight limit?
      if acceptable_combinations_of_size_i(variants, i, limit).size > 0
        return acceptable_combinations_of_size_i(variants, i, limit)
      end
    end
    # Return an empty array if the limit cannot be satisfied
    # i.e. lightest variant is heavier than the limit
    return []
  end

  def acceptable_combinations_of_size_i(items, i, limit)
    # Finds all possible combinations (subsets) of size i (without repeating);
    # then selects only ones that satisfy the weight limit.
    items.combination(i).select {|comb| weight_of_variants(comb) <= limit}
  end

  def select_cheapest_combination(combinations)
    prices = combinations.each_with_index.map do |comb, index|
      [price_of_variants(comb), index]
    end
    cheapest_combo = prices.min
    index = cheapest_combo[1]
    combinations[index]
  end

  def update_products_to_purchase(products, message)
    @products_to_purchase = products
    @message = message
  end

  def price_of_variants(variants)
    variants.inject(0){ |sum, variant| sum + variant.price }
  end

end

Shopicruit.run(limit: 100, desired_categories: ["Computer", "Keyboard"])