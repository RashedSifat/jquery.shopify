assert = require('assert')
$      = require('jquery')
global.jQuery = $

require('../src/jquery.shopify')

describe 'jquery.shopify', ->
  describe 'products', ->
    it 'hello, world', ->
      $widget = $('<div id="shopify-widgets"></div>').shopify({shop: 'matt', cart_indicator: '.shopify-widget-cart'})
      assert.equal $widget.attr('id'), 'shopify-widgets'

    it 'findProductIds', ->
      html = """
        <div id="shopify-widgets">
          <div class="shopify-widget-product" data-product-handle="colombia-los-idolos-decaf"></div>
          <div class="shopify-widget-product" data-product-handle="123-w-longitude-blend"></div>
        </div>
      """
