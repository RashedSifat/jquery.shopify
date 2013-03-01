$            = jQuery
$.shopify    = {}
$.shopify.fn = {}
$.fn.shopify = (method, args...) ->
  $.shopify.fn[method].apply(this, args)

# Utils

PRODUCTS       = {}
SHOP           = ""
CART_INDICATOR = ""
BUY_BUTTON     = ""
STYLE          = ""

# Classes

class window.Product
  render: ->
    node = $(".shopify-widget-product[data-product='#{@handle}']")
    node.find("[data-product-title]").text @title
    node.find("[data-product-body-html]").html @body_html

# Private

_getJSONFromCookie = ->
  cookie = $.cookie('cart')
  products = JSON.parse(cookie) if cookie

_serializeCartToUrl = ->
  if products = _getJSONFromCookie()
    quantities = for key, value of products
      product = $.shopify.requestDataFromHandle(key)
      id = product.variants[0].id
      "#{id}:#{value}"
    window.location.replace "http://dundas.myshopify.com/cart/#{quantities.join(',')}"

# Cart
initCart = ->
  renderCart()

renderCart = ->
  renderCartQuantity()
  renderCartList()

renderCartQuantity = ->
  if products = _getJSONFromCookie()
    quantities = (value for key, value of products)
    count = quantities.reduce (t, s) -> t + s
    $("[data-cart-length]").html("<span>(#{count} items)</span>")
  else
    $("[data-cart-length]").html("")

renderCartList = ->
  if products = _getJSONFromCookie()
    html = for key, value of products
      title = $.shopify.requestDataFromHandle(key).title
      "<li>#{title} (#{value})</li>"
    $("#cart-empty").addClass 'hidden'
    $("#cart-items").removeClass 'hidden'
    $("#cart-items").html(html)
  else
    $("#cart-items").html("")

# Add to Cart
initAddToCartButtons = ->
  $("[data-add-product]").on 'click', ->
    $(this).trigger 'add-product'

  $("#shopify-widgets").on 'add-product', (event) ->
    handle = $(event.target).parents("[data-product]").data("product")
    product = $.shopify.requestDataFromHandle handle
    $.shopify.addProductToCart product

# Checkout
initCheckoutButton = ->
  $("[data-checkout]").on 'click', ->
    _serializeCartToUrl()

# Public

$.shopify.addProductToCart = (product) ->
  $("#cart-empty").addClass 'hidden'
  $("#cart-items").removeClass 'hidden'
  cart = if cookie = $.cookie('cart') then JSON.parse(cookie) else {}
  cart[product.handle] = if cart[product.handle] then cart[product.handle] + 1 else 1
  $.cookie('cart', JSON.stringify(cart))
  renderCart()

#Scan the DOM and find all the matching product ids
$.shopify.scanDOMForProducts = ->
  $(".shopify-widget-product").map (_, node) ->
    $(node).data("product")

$.shopify.requestDataFromHandle = (handle, callback) ->
  if product = PRODUCTS[handle]
    callback?()
    product
  else
    $.ajax
      url: "http://simpledomainsomg.com/products/#{handle}.json"
      dataType: 'jsonp'
      success: (response) ->
        product = new Product
        product[key] = value for key, value of response.product
        PRODUCTS[handle] = product
        product.render()
        callback?()

$.shopify.loadProducts = (callback) ->
  handles = $.shopify.scanDOMForProducts()
  finishedIDS = []
  handles.map (_, handle) ->
    $.shopify.requestDataFromHandle handle, ->
      # wait until all the callbacks have fired :P
      finishedIDS.push handle
      callback() if handles.length is finishedIDS.length

#Initialize the Shopify jQuery plugin
$.shopify.start = (options={}) ->
  SHOP           = options.shop
  CART_INDICATOR = options.cart_indicator
  BUY_BUTTON     = options.buy_button
  STYLE          = options.style

  $.shopify.loadProducts ->
    initCart()
    initAddToCartButtons()
    initCheckoutButton()

  this

window.PRODUCTS = PRODUCTS
