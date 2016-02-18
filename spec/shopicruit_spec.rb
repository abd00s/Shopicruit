require  "./shopicruit"

describe 'Shopicruit' do
  describe '#initialize' do
    let(:test) {Shopicruit.new(1,["Potatoes"])}
    # test = Shopicruit.new(1,["Potatoes"])
    it 'instantiates Shopicruit with initial state' do
      expect(test).to have_attributes(
        limit: 1,
        desired_categories: ["Potatoes"],
        desirable_products: [],
        desirable_variants: [],
        products_to_purchase: [],
        message: []
      )
    end
  end
end