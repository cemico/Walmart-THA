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
- server data is incomplete, some records do not have a shortDescription and longDescription
- server data has extra fields in it now shown on docs page
- server data has embedded \u{ef} chars which do not print

Submission 10/4/2017 - Xcode 9 / Swift 4

where to start, lots of area, sure I'll miss and gloss over quite a bit.
1. setup the api key in the common fashion of embedding it in the build project under user defines, which import into info.plist, which access withi the app.  this is an easy way to have separate keys for different environments w/o any coding changes.
2. I noticed the data wasn't quite spot on, see "Observations", above
3. I setup the app as requested, landing page is a products table list, and the details page is also a table view of the details.  I used the real walmart app and amazon and ebay as comparisons of what work well.  I added the full details link as a separate page off the details page, like the walmart app has.
4. I have logic in place to pre-fetch the next chunk of data for lazy loading the products table set such that when the user is getting close to a threshold limit, it'll fetch it before the end of the table.  I didn't spent a lot of time on notifications ... used the title to show the "loading..." status, as well as the current product count (also added the row number on the list to better know where you are in the list, bottom left).  when new data arrives, I used the newer haptic feedback for both sound / feel that something has occurred, so when your phone buzzes slightly, that's what that is going on.
5. I cache the images, both internally, and off on the device.  this demonstrates file code and organization.  I also do something similar w/ the data, but did that using the nscoding and nsarchiving/unarchiving methods, since the dataset is limited, and I wanted to be able to view the saved data in the simulator (same w/ images) to make sure thing are as expected.  this shows full object roundtrip lifecycle from device to memory.
I created two model classes to accomodate the server data.  one represents a single product, and the other represents the paged datasets.  internally I keep the product items.  these demonstrate the NSCoding, CustomStringConvertible, and Equitable protocols.  oh, also did a slick way of implementing the "description" conformance as an extension.
that's a nice segue into much support for various items via extensions.  you'll find a separate folder labeled as such, as you will other organizational items.  I also store a single user defaults item via here, another datastrore end target.
on the networking, I set it up using the genereic enum typed way that has been gaining popularity over the past few years.  this is a comon way for AlamoFire, but I did it in a generic way to support any root networking, which as requested, used system calls.  there is only one endpoint within here, so it's a lot of setup for little bang, but an example of a nice framework which is easily expandable for multiple endpoints with varying needs in varying formats.  you'll find that in the Router file.
there are two data controllers structured as singletons.  one manages the network data / product related modelled data, and the other handles more app specific items, and is the gateway to dealing with the cache and backend file management.  two other singletons exist for lower level cache support and that haptic feedback support (figured a good start for more sounds and vibration support)
I wrote a custom ratings star class, actually was the first thing I did.  I did it in a simple test project, which is a supporting project in the build file.  inside here, I set it up to support dynamic interface builder properties (where you can see and edit properties visually).  I set it up to auto scale, support any number of stars, be able to pass in colors for various parts, custom shapes, ect.  the star is built on the fly with core graphics.  the test project has a single star to demonstrate dual feedback, and then also has a container multi-star view which supports what you see in the app.  I also wrote a number of unit tests for this control, which you'll find under that project in the RatingStarsTests folder ... thought I'd demonstrate a bit of that too ;)
I usually separate and modularize the code much more - it's not bad, but usually is much more concise.  I had to prioritize things as time got closer.  another one I opted out of doing for making a better user experience with multiple devices is the Bonus item of swiping to view next/prev item.  this would have been easy, probably should have done it up front, as I'm very versed with collection views, which is what I'd have used, a collection mirroring the table's dataset, set the model on entry and position to the proper cell.  I'd setup a delegate protocol to the master, and when the details encountered a swipe, and the collectionview asked for that new cell, I'd get the data from the master.  I'd likely have had a 3 ring buffer for data models, always having the current and each side to make swipes quick.  I also planned to set it up with paging, so you'd have an even page swipe each time.  but, that part you'll just have to image ;)
I did spend a good chunk of time on all the various cases of multiple devices in multiple orientations.  I setup the app as a splitview controller, so you got most of the desired display out of the box, yet there was still a lot of refining for various cases.  in the end, believe it handles everything, or near to it, for any device in any orientation.  I also setup custom sizing classes so that ipad displays had a little more display area for the image and positioning of the text fields, over the smaller iphone displays.  within there, also have dynamic label sizing and matching controls repositioning via constraints, if the name value needed one line or two on it's display.  that one is pretty subtle, but thought it was nice.
part of the guidelines mentioned fun ... did have some fun, added initial animation of the data on first load, little spring into placement action.  that and a number of little things, like the haptic feedback, auto-sizing, file caching, etc. was fun :)
I hijacked some graphics online, gave it a rough Walmart look, also used the blue/orange where noted.
I figured the cached items could be auto-cleared on some end logic.  maybe everything on a version bump, or data on a time boundary, 30 minutes, or whatever would make sense.  I figure if the user was continually in the app, start, re-run, etc., for 5 or 10 minutes, for this test with fixed data, that was a nice way to improve performance, and also give it a working capability for offline mode.  I wrote the routines to clean up the cache, just didn't provide a hook for them to be called.  if you run the app in the simulator, you find the items stored in the typical existing "Cache" folder.  I set that up as a dictionary lookup to the individual cached files for quicker file retrieval, no lists to iterate through, direct access.
I utilized enums all over, some with arguments, others without, also made good use of constant definitions.
I wrote some routines to handle the html, also some data cleansing.  I played around with a true webview, but opted for the converted data into an attributed string and set directly in a text view.
what else ... the online access goes through a few checks, does it exist in memory cache first, then file cache, then for records, are we at the end, and then pulls an online chunk.  I set the count to 25 on the chunks, tested in various throttled throughput, seemed a nice round number and not too much data, gave for more user scroll and enough pre-fetch runway to get more to allow scrolling more smoothly.
the code has the typical exception handling, optionally and catching, even throwing a few custom errors.
I handle thread safety few different ways, normal GCD queue management, also some synchronous paths.
I've been using this way to name my reuse ids for years, just saw somebody else use it this year, where you have the id match the class name, then it makes access in the code w/o strings, and easier to know a structured pattern on the naming convention
there's your usual syntax for flow, guard, if/let, had defer in there, forget if I took it out or not, nil coalescing, etc.  there's a handful of swift 4 only syntax in there, oh, should state that at the top, will add the dev environment.
have a spot or two for lazy property initialization with closure syntax to init and create, love that clean way to localize that code, and also overcomes the init requirement that it needs to be fully initialized at start, dual win
that's what I recall - rest is pretty basic app layout.  I did play around with a few other things, some custom scroll animation and such, but opted to take it out, left it commented in the code.  oh, shoot, forgot to mention, started to add a search filter capability to the products page.  it's working, as far as I can tell, but didn't test it a whole lot, but it is there, thought it'd be nice on that products page with potentially so many results.

enjoy,
dave
