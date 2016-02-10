require_relative "Api"
require_relative "Product"
require_relative "Variant"
require_relative "Utility"

class Shopicruit
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

end

