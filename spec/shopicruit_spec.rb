require  "./shopicruit"

describe 'Shopicruit' do
  # Possible Scenarios
  # Case 1: Limit is high enough to purchase all products (context_1)
  # Case 2: Limit is low, can purchase some products or none.
  ## Case 2(a): Limit is too low, can't purchase any product (context_2)
  ## Case 2(b): Limit allows purchase of some products, but not all
  ### Case 2(b)(i): Produces one purchasable combination (context_3)
  ### Case 2(b)(ii): Produces multiple purchasable combinations (context_4)
  let(:context_1) { Shopicruit.new(16,["Keyboard", "Computer"]) }
  let(:context_2) { Shopicruit.new(0.5,["Keyboard", "Computer"]) }
  let(:context_3) { Shopicruit.new(6,["Keyboard", "Computer"]) }
  let(:context_4) { Shopicruit.new(7,["Keyboard", "Computer"]) }

  let(:sample_products) {[
    {
      "title" => "Sample Product 1",
      "product_type" => "Keyboard",
      "variants" => [
        {
          "title" => "Sample Variant 1-a",
          "price" => "10",
          "grams" => 3000
        },
        {
          "title" => "Sample Variant 1-b",
          "price" => "15",
          "grams" => 2000
        }
      ]
    },
    {
      "title" => "Sample Product 2",
      "product_type" => "Computer",
      "variants" => [
        {
          "title" => "Sample Variant 2-a",
          "price" => "13",
          "grams" => 5000
        },
        {
          "title" => "Sample Variant 2-b",
          "price" => "8",
          "grams" => 4000
        }
      ]
    },
    {
      "title" => "Sample Product 3",
      "product_type" => "Keyboard",
      "variants" => [
        {
          "title" => "Sample Variant 3-a",
          "price" => "17",
          "grams" => 1000
        }
      ]
    },
    {
      "title" => "Sample Product 4",
      "product_type" => "Wallet",
      "variants" => [
        {
          "title" => "Sample Variant 4-a",
          "price" => "12",
          "grams" => 100
        }
      ]
    }
  ]}

  # Before hook to populate @desirable_products and @desirable_variants
  before do |example|
    unless example.metadata[:skip_before]
      scenario.filter_products(sample_products)
      scenario.find_all_desirable_variants
    end
  end

  let(:scenario) { context_1 }

  describe '#initialize' do
    it 'instantiates Shopicruit with initial state', :skip_before do
      expect(scenario).to have_attributes(
        limit: 16,
        desired_categories: ["Keyboard", "Computer"],
        desirable_products: [],
        desirable_variants: [],
        products_to_purchase: [],
        message: []
      )
    end
  end

  describe "#filter_products" do
    it "populates our instance's @desirable_products", :skip_before do
      expect {scenario.filter_products(sample_products)}.to change {scenario.desirable_products.empty?}
      .from(true).to(false)
    end

    it "only selects products matching our required categories", :skip_before do
      scenario.filter_products(sample_products)
      expect(scenario.desirable_products).to all satisfy { |product|
        product.type == "Computer" || product.type == "Keyboard"
      }
    end

    it "populates instance's @desirable_products with Product objects", :skip_before do
      scenario.filter_products(sample_products)
      expect(scenario.desirable_products).to all be_instance_of(Product)
    end
  end

  describe "#find_all_desirable_variants" do
    it "populates our instance's @desirable_variants", :skip_before do
      scenario.filter_products(sample_products) #products need to be populated beforehand
      expect {scenario.find_all_desirable_variants}
      .to change {scenario.desirable_variants.empty?}
      .from(true).to(false)
    end

    it "associates each variant to its parent product" do
      expect(scenario.desirable_variants).to all satisfy { |variant|
        variant.parent.type == "Computer" || variant.parent.type == "Keyboard"
      }
    end

    it "populates instance's @desirable_variants with Variant objects" do
      expect(scenario.desirable_variants).to all be_instance_of(Variant)
    end
  end

  describe "#weight_of_variants" do
    it "sums input variants' weight"  do
      expect(scenario.weight_of_variants(scenario.desirable_variants)).to eq(15.0)
    end
  end

  describe "#price_of_variants" do
    it "sums input variants' price"  do
      expect(scenario.price_of_variants(scenario.desirable_variants)).to eq(63.0)
    end
  end

  context "-Case 1: Limit is high enough to purchase all products" do
    let(:scenario) { context_1 }

    describe "#find_carriable_combo" do
      it "adds all filtered products to @products_to_purchase" do
        expect {scenario.find_carriable_combo(scenario.desirable_variants, scenario.limit)}
        .to change {scenario.products_to_purchase.count}.from(0).to(5)
      end

      it "updates output @message to \"The total weight of all desired variants is under the weight limit you may purchase all.\"" do
        expect {scenario.find_carriable_combo(scenario.desirable_variants, scenario.limit)}
        .to change {scenario.message}
        .from([]).to("The total weight of all desired variants is under the weight limit you may purchase all.")
      end
    end
  end

  context "-Case 2: Limit is low, can purchase some products or none." do

    context "--Case 2(a): Limit is too low, can't purchase any product" do
      let(:scenario) { context_2 }

      describe "#find_combinations" do
        it "returns an empty array (of products) because they're each individually too heavy" do
          expect(scenario.find_combinations(scenario.desirable_variants,scenario.limit))
          .to eq([])
        end
      end

      describe "#find_carriable_combo" do
        it "does not add any product to @products_to_purchase" do
          expect {scenario.find_carriable_combo(scenario.desirable_variants, scenario.limit)}
          .to_not change {scenario.products_to_purchase.count}
        end

        it "updates output @message to \"All variants are too heavy, you can't purchase any.\"" do
          expect {scenario.find_carriable_combo(scenario.desirable_variants, scenario.limit)}
          .to change {scenario.message}
          .from([]).to("All variants are too heavy, you can't purchase any.")
        end
      end
    end

    context "--Case 2(b): Limit allows purchase of some products, but not all" do

      let(:scenario) { context_3 }

      describe  "#acceptable_combinations_of_size_i" do
        it "finds combinations (subsets/groupings) of input variants that are within the limit" do
          scenario.desirable_variants.count.downto(1) do |i|
            if scenario.acceptable_combinations_of_size_i(scenario.desirable_variants, i, scenario.limit).size > 0
              expect(scenario.acceptable_combinations_of_size_i(scenario.desirable_variants, i, scenario.limit))
              .to all satisfy { |comb| scenario.weight_of_variants(comb) <= scenario.limit }

              # # Uncomment to see details in output
              # scenario.acceptable_combinations_of_size_i(scenario.desirable_variants, i, scenario.limit).each do |comb|
              #   combination = "("
              #   comb.each {|i| combination += "[#{i.title}, #{i.weight} KG]"}
              #   combination << ")"
              #   puts "\t"+combination
              #   puts "\tTotal weight of this combination is #{scenario.weight_of_variants(comb)} KG; which is within the limit of #{scenario.limit} KG"
              #   puts
              # end

            end
          end
        end
      end

      describe "#find_carriable_combo" do
        it "updates output @message to \"This selection of variants is the most you can carry while remaining under the limit\"" do
          expect {scenario.find_carriable_combo(scenario.desirable_variants, scenario.limit)}
          .to change {scenario.message}
          .from([]).to("This selection of variants is the most you can carry while remaining under the limit")
        end
      end

      context "---Case 2(b)(i): Produces one purchasable combination" do
        describe "#find_combinations" do
          it "returns `only` one selection of purchasable products" do
            expect(scenario.find_combinations(scenario.desirable_variants, scenario.limit).size)
            .to eq(1)
          end
        end
      end

      context "---Case 2(b)(ii): Produces multiple purchasable combinations" do
        let(:scenario) { context_4 }

        describe "#find_combinations" do
          it "returns all combinations of purchasable products" do
            expect(scenario.find_combinations(scenario.desirable_variants, scenario.limit).size)
            .to be > 1
          end
        end

        describe "#select_cheapest_combination" do
          it "out of possible purchasable combinations, selects the cheapest" do
            combinations = scenario.find_combinations(scenario.desirable_variants, scenario.limit)
            price_of_combinations = Hash.new
            combinations.each_with_index {|c, i| price_of_combinations["combination #{i+1}"] = scenario.price_of_variants(c)}
            minimmum_price = price_of_combinations.values.min
            selected_combination = scenario.select_cheapest_combination(combinations)

            # # Uncomment to see details in output
            # combinations.each do |comb|
            #   combination = "("
            #   comb.each {|i| combination += "[#{i.title}, #{i.weight} KG, $#{i.price}]"}
            #   combination << ")"
            #   puts "\t\t"+combination
            #   puts "\t\tTotal weight of this combination of #{comb.size} products is #{scenario.weight_of_variants(comb)} KG; which is within the limit of #{scenario.limit} KG"
            #   puts "\t\tTotal price of this combination is $#{scenario.price_of_variants(comb)}"
            #   puts
            # end

            expect(scenario.price_of_variants(selected_combination))
            .to eq(minimmum_price)
          end
        end
      end
    end
  end
end