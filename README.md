# Walmart-THA

server docs: https://walmartlabs-test.appspot.com/

Walmart Mobile Engineering app assignment:
- Create a new application with WalmartLabs Code Test API integrated. The application should have two screens.
- We’ll be looking at your coding style, use of data structures, collections, and overall Platform SDK knowledge.
- It’s up to you to impress us with this assignment. The list of a products can be a simple or as fancy as you’d like it to be.
- Include product image for each product.
- Try to have some fun.
- Don’t use any 3rd party networking libraries like AFNetworking or AlamoFire.
Screen 1:
- First screen should contain a List of all the products returned by the Service call.
- The list should support Lazy Loading. When scrolled to the bottom of the list, start lazy loading next page of products and append it to the list.
Screen 2:
- Second screen should display details of the product.
BONUS: Ability to swipe to view next/previous item ( Eg: Gmail App)
BONUS: Universal app that works on both iPad and iPhone.


Observations 10/1/2017 (assuming all these are part of the test)
- server docs are misleading, talks of pageNumber / pageSize when in fact it is really recordNumber / pageSize (count)
- server data is inaccurate, displays 224 items, only 223 are returned
- server data is incomplete, some records do not have a shorDescription and longDescription
- server data has extra fields in it now shown on docs page
- server data has embedded \u{ef} chars which do not print
