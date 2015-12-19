require "HTTParty"
require_relative "Product"
class Main
  include HTTParty
  def initialize
    @desired_products = []
  end

  def get_products
    response = HTTParty.get('http://shopicruit.myshopify.com/products.json')
    response["products"]
  end

  def filter_desired_products(products)
    products.each do |product|
      if ["Computer", "Keyboard"].include?(product["product_type"])
        @desired_products << Product.new(product)
      end
    end
  end
end