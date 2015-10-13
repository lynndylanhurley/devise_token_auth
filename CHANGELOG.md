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