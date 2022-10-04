@place_order_guest_customer
Feature: Submitting order
    In order buy a product
    As a guest
    I need to be able to place an order

    Background:
        Given the store operates on a single channel in "United States"
        And there is a customer "Gordon Freeman" identified by an email "gfreeman@resistance.com" and a password "123456"
        And the store has a product "Jack Daniels Gentleman" priced at "$30.00"
        And the store has a product "Jim Beam" priced at "$20.00"
        And the store allows shipping with "Pickup" identified by "pickup"
        And the store has a payment method "Cash" with a code "cash"
        And the store has promotion "Black Friday" with coupon "bfriday"
        And this promotion gives "50%" discount to every order

    @graphql
    Scenario: Placing order
        When I prepare query to fetch all products
        And I send that GraphQL request
        Then I should receive a JSON response
        And I save key 'collection.0.variants.collection.0.id' of this response as "firstProductVariantIri"
        And I save key 'collection.1.variants.collection.0.id' of this response as "secondProductVariantIri"

        When I prepare create cart operation
        Then I send that GraphQL request
        And I save key 'order.id' of this response as "orderId"
        And I save key 'order.tokenValue' of this response as "orderToken"

        When I prepare add product to cart operation
        And I set 'quantity' field to integer 2
        And I set 'productVariant' field to value "firstProductVariantIri"
        And I set 'orderTokenValue' field to value "orderToken"
        Then I send that GraphQL request
        And I save key 'order.items.edges.0.node._id' of this response as "firstOrderItemId" as "string"

        When I prepare add product to cart operation
        And I set 'quantity' field to integer 1
        And I set 'productVariant' field to value "secondProductVariantIri"
        And I set 'orderTokenValue' field to value "orderToken"
        Then I send that GraphQL request
        And I save key 'order.items.edges.1.node._id' of this response as "secondOrderItemId" as "string"
        And total price for items should equal to "8000"

        When I prepare remove product from cart operation
        And I set 'id' field to value "orderId"
        And I set 'orderItemId' field to value "firstOrderItemId"
        Then I send that GraphQL request
        And total price for items should equal to "2000"

        When I prepare operation to add order shipping address
        And I set 'email' field to "gfreeman@resistance.com"
        And I set 'orderTokenValue' field to value "orderToken"
        And I set 'shippingAddress' object "firstName" property to "John"
        And I set 'shippingAddress' object "lastName" property to "Doe"
        And I set 'shippingAddress' object "countryCode" property to "US"
        And I set 'shippingAddress' object "city" property to "Chicago"
        And I set 'shippingAddress' object "street" property to "Sunny Street"
        And I set 'shippingAddress' object "postcode" property to "45222"
        And I set shippingAddress field to value "shippingAddress"
        And I send that GraphQL request
        And This response should contain "order.shippingAddress.firstName" equal to "John"
        And I save key 'order.shipments.edges.0.node._id' of this response as "orderShipmentId"

        When I prepare operation to add order billing address
        And I set 'email' field to "gfreeman@resistance.com"
        And I set 'orderTokenValue' field to value "orderToken"
        And I set 'billingAddress' object "firstName" property to "Jane"
        And I set 'billingAddress' object "lastName" property to "Doe"
        And I set 'billingAddress' object "countryCode" property to "US"
        And I set 'billingAddress' object "city" property to "Chicago"
        And I set 'billingAddress' object "street" property to "Sunny Street"
        And I set 'billingAddress' object "postcode" property to "45222"
        And I set billingAddress field to value "billingAddress"
        And I send that GraphQL request
        And This response should contain "extensions.message" equal to "Provided email address belongs to another user, please log in to complete order."

