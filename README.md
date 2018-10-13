# atos-gui

A GUI wrapper for [atos](https://developer.apple.com/library/archive/technotes/tn2151/_index.html#//apple_ref/doc/uid/DTS40008184-CH1-SYMBOLICATE_WITH_ATOS)

## How to use

1. Place __YourApp.app__ and __YourApp.app.dSYM__ in the same directory
2. Launch __atos-gui__
3. Chose __YourApp.app__
4. Paste the crash log into __atos-gui__
5. Press __⌘R__ to re-symbolicate

### Manually Set Load Address

Normally __atos-gui__ should be able to find the load address from the crash log, if it fails to find it, you can manually set it at the buttom text field.
