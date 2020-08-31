iOS-JP10Key [![Apache License 2.0](https://img.shields.io/badge/license-Apache%202.0-yellow.svg?style=flat)](https://www.tldrlegal.com/l/apache2)
===================

[Mozc-for-iOS](https://github.com/yusakuw/Mozc-for-iOS)を使ったフリックキーボードのサンプル実装です。  
https://github.com/kishikawakatsumi/JapaneseKeyboardKit を参考に、細かな挙動とUIを変更し、Swift化しています。  
[Mozc](https://code.google.com/p/mozc/)はC++であるため、一部Objective-C++のコードを残しています。

### System Requirements

    macOS 10.15 Catalina
    Xcode 11.6
    iOS SDK 13
    Python 2.7.10 (for build mozc-for-ios)

### Usage

#### Getting the code

```
$ git clone https://github.com/yusakuw/iOS-JP10Key.git --recursive
$ cd iOS-JP10Key
```

#### Build Mozc (Japanese Input Method)

##### Configure

```
$ cd Mozc-for-iOS/src
$ python build_mozc.py gyp
```

##### Compilation

```
$ python build_mozc_ios.py
```

#### Run Sample Project

```
$ cd ../..
$ open iOS-JP10Key.xcodeproj
```

[Apache]: http://www.apache.org/licenses/LICENSE-2.0
[MIT]: http://www.opensource.org/licenses/mit-license.php
[GPL]: http://www.gnu.org/licenses/gpl.html
[BSD]: http://opensource.org/licenses/bsd-license.php

## License

iOS-JP10Key is available under the [Apache license][Apache]. See the LICENSE file for more info.

