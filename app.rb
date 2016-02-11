require_relative "Shopicruit"

class App
  def self.run
    shopicruit = Shopicruit.new
    shopicruit.filter_products
    shopicruit.find_all_desirable_variants
    shopicruit.find_carriable_combo(shopicruit.desirable_variants, shopicruit.limit)
    puts shopicruit.message
    shopicruit.products_to_purchase.each do |product|
      puts "\t#{product.parent.title}"
      puts "\t\t#{product.title}"
    end
    puts "Weighing #{(shopicruit.weight_of_variants(shopicruit.products_to_purchase))} KGs"
    puts "Costing you $#{shopicruit.price_of_variants(shopicruit.products_to_purchase)}"
  end
end

App.run