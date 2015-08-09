+<a name="0.1.33"></a>
+# 0.1.33 (2015-??-??)
+
+## Features
+
+- **Improved OAuth Flow**: Supports new OAuth window flows, allowing options for `sameWindow`, `newWindow`, and `inAppBrowser`
+
+## Breaking Changes
+
+- The new OAuth redirect behavior now defaults to `sameWindow` mode, whereas the previous implementation mimicked the functionality of `newWindow`. This was changed due to limitations with the `postMessage` API support in popular browsers, as well as feedback from user-experience testing.