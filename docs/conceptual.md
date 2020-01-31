# Conceptual

None of the following information is required to use this gem, but read on if you're curious.

## About token management

Tokens should be invalidated after each request to the API. The following diagram illustrates this concept:

![password reset flow](https://github.com/lynndylanhurley/ng-token-auth/raw/master/test/app/images/flow/token-update-detail.jpg)

During each request, a new token is generated. The `access-token` header that should be used in the next request is returned in the `access-token` header of the response to the previous request. The last request in the diagram fails because it tries to use a token that was invalidated by the previous request.

The only case where an expired token is allowed is during [batch requests](#about-batch-requests).

These measures are taken by default when using this gem.

## About batch requests

By default, the API should update the auth token for each request ([read more](#about-token-management)). But sometimes it's necessary to make several concurrent requests to the API, for example:

##### Batch request example

~~~javascript
$scope.getResourceData = function() {

  $http.get('/api/restricted_resource_1').success(function(resp) {
    // handle response
    $scope.resource1 = resp.data;
  });

  $http.get('/api/restricted_resource_2').success(function(resp) {
    // handle response
    $scope.resource2 = resp.data;
  });
};
~~~

In this case, it's impossible to update the `access-token` header for the second request with the `access-token` header of the first response because the second request will begin before the first one is complete. The server must allow these batches of concurrent requests to share the same auth token. This diagram illustrates how batch requests are identified by the server:

![batch request overview](https://github.com/lynndylanhurley/ng-token-auth/raw/master/test/app/images/flow/batch-request-overview.jpg)

The "5 second" buffer in the diagram is the default used this gem.

The following diagram details the relationship between the client, server, and access tokens used over time when dealing with batch requests:

![batch request detail](https://github.com/lynndylanhurley/ng-token-auth/raw/master/test/app/images/flow/batch-request-detail.jpg)

Note that when the server identifies that a request is part of a batch request, the user's auth token is not updated. The auth token will be updated and returned with the first request in the batch, and the subsequent requests in the batch will not return a token. This is necessary because the order of the responses cannot be guaranteed to the client, and we need to be sure that the client does not receive an outdated token *after* the the last valid token is returned.

This gem automatically manages batch requests. You can change the time buffer for what is considered a batch request using the `batch_request_buffer_throttle` parameter in `config/initializers/devise_token_auth.rb`.
