require_relative "Api"
require_relative "Product"
require_relative "Variant"
require_relative "Utility"

class Shopicruit
  attr_reader :desirable_variants, :limit
  extend Utility

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

  def self.run
    shopicruit = Shopicruit.new
    shopicruit.filter_products
    shopicruit.find_all_desirable_variants
    find_carriable_combo(shopicruit.desirable_variants, shopicruit.limit)
  end

end

Shopicruit.run