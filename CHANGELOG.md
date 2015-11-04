<a name="0.1.37"></a>
# 0.1.37 (beta)

## Features

- **Standard Devise**: Allow conditional support of legacy Devise. Now defaults to disabled.
- **Localization**: Add German translation(de)
- **Batch Requests**: Prevent batching of requests by appending `unbatch=true` param to request URL

## Fixes

- **URL Helper**: Preserve query parameters when building urls

## Breaking Changes

- This version updates legacy Devise support to default to disabled rather than enabled. This support causing all sorts of random issues for people who may not have needed the integration. This feature is considered experimental.


<a name="0.1.36"></a>
# 0.1.36 (2015-10-13)

## Fixes

- **Deps**: Revert to last known working mysql2 gem for Travis


<a name="0.1.35"></a>
# 0.1.35 (2015-10-13)

## Features

- **Localization**: Add Polish translation (pl)

## Fixes

- **OAuth**: Fix error in setting text on redirect page
- **OAuth**: Fully support OmniauthCallbacksController action overrides
- **OAuth**: Don't serialize the entire user object in redirect URLs
- **Rails-API**: Fix Rails-API integration hang-ups
- **Namespaces**: Correct handling namespaced resources

## Misc

- **Code Quality**: Restrict access to controller methods and other cleanup
- **Deps**: Update to Devise v3.5.2


<a name="0.1.34"></a>
# 0.1.34 (2015-08-10)

## Features

- **Localization**: Add Brazilian Portuguese translation (pt-BR)

## Fixes

- **Deps**: Lock Devise to last known working version (v3.5.1)


<a name="0.1.33"></a>
# 0.1.33 (2015-08-09)

## Features

- **Improved OAuth Flow**: Supports new OAuth window flows, allowing options for `sameWindow`, `newWindow`, and `inAppBrowser`

## Breaking Changes

- The new OmniAuth callback behavior now defaults to `sameWindow` mode, whereas the previous implementation mimicked the functionality of `newWindow`. This was changed due to limitations with the `postMessage` API support in popular browsers, as well as feedback from user-experience testing.
