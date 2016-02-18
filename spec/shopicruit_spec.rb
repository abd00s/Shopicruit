require  "./shopicruit"

describe 'Shopicruit' do
  let(:test) {Shopicruit.new(100,["Wallet"])}
  describe '#initialize' do
    it 'instantiates Shopicruit with initial state' do
      expect(test).to have_attributes(
        limit: 100,
        desired_categories: ["Wallet"],
        desirable_products: [],
        desirable_variants: [],
        products_to_purchase: [],
        message: []
      )
    end
  end

  describe "#filter_products" do
    it "populates our instance's desirable products" do
      expect {test.filter_products}.to change {test.desirable_products.empty?}
      .from(true).to(false)
    end

    it "only selects products matching our required categories" do
      test.filter_products
      expect(test.desirable_products). to all satisfy { |product|
        product.type == "Wallet"
      }
    end

    it "populates instance's desirable products with Product objects" do
      test.filter_products
      expect(test.desirable_products). to all be_instance_of(Product)
    end
  end
end