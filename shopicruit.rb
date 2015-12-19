require_relative "Api"
require_relative "Product"

class Shopicruit
  all_products = Api::get_products
  desirable_products = all_products.select { |product| ["Computer", "Keyboard"]
    .include?(product["product_type"]) }
  desirable_products.map! { |product| Product.new(product)}
end
