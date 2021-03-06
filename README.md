# Shopicruit

### Submission for Shopify's Summer Internship application code challenge.

Brief: You've discovered the Shopify Store 'Shopicruit'. Since you're obsessed with computers, you want to buy every single computer and keyboard variant they have to offer. Unfortunately you can only carry up to 100kg and may not be able to buy all of them. By inspecting the JavaScript calls on the store you discovered that the shop lists products at http://shopicruit.myshopify.com/products.json. Write a program that calculates what the maximum amount of computers and keyboards that you could carry would cost you.

---

Please run `bundle`, followed by `rspec` to run the program including the spec suite, or run the file `shopicruit.rb` to run the program without the spec suite.

Assumptions made:
* All variants are available.
* Only one count of each variant is to be purchased (no repeats).
* If more than one carriable combination (of the same size) is achievable, select the cheaper one.
* API JSON response structure remains as retrieved on 22/2/2016.
* Valid internet connection is available to successfully hit API.
