require "./Api"

class Shopicruit
  all_products = Api::get_products
  desirable_products = all_products.select { |product| ["Computer", "Keyboard"]
    .include?(product["product_type"]) }
  puts all_products.count
  puts desirable_products.count
end
