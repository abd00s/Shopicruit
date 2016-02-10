require_relative "Api"
require_relative "Product"
require_relative "Variant"
require_relative "Utility"

class Shopicruit
  attr_reader :desirable_variants, :limit, :products_to_purchase, :message

  def initialize
    @limit = 1000
    @desired_categories = ["Computer", "Keyboard"]
    @desirable_products = []
    @desirable_variants = []
    @products_to_purchase = []
    @message = []
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
        @desirable_variants << Variant.new(variant)
      end
    end
  end

  def weight_of_variants(arr)
    arr.inject(1){ |sum, variant| sum + variant.grams }
  end

  def find_carriable_combo(variants, limit)
    if weight_of_variants(variants) <= limit
      # buy all
      message = "The total weight of all desired variants is under the weight limit
      you may purchase all."
      update_products_to_purchase(variants, message)
    elsif find_combinations(variants, limit).empty?
      # buy none
      message = "All variants are too heavy, you can't purchase any."
    else
      # COMBS << find_combinations(variants, limit)
      message = "This selection of variants is the most you can carry while
      remaining under the limit"
      # if there are 2 combs, select the cheaper one
    end
  end

  def update_products_to_purchase(products, message)
    @products_to_purchase = products
    @message = message
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

  def self.run
    shopicruit = Shopicruit.new
    shopicruit.filter_products
    shopicruit.find_all_desirable_variants
    shopicruit.find_carriable_combo(shopicruit.desirable_variants, shopicruit.limit)
  end

end

Shopicruit.run