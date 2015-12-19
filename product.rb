class Product
  attr_reader :title, :type, :variants

  def initialize(product)
    @title = product["title"] if product["title"]
    @type = product["product_type"] if product["product_type"]
    @variants = product["variants"] if product["variants"]
  end
end



