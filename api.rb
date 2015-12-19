require "HTTParty"

module Api
  include HTTParty

  def self.get_products
    response = HTTParty.get('http://shopicruit.myshopify.com/products.json')
    response["products"]
  end
end