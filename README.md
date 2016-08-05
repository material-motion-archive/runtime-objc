# Material Motion Runtime for Apple Devices

[![Build Status](https://travis-ci.org/material-motion/material-motion-runtime-objc.svg?branch=develop)](https://travis-ci.org/material-motion/material-motion-runtime-objc)

The Material Motion Runtime is a tool for describing motion declaratively.

## Declarative motion, aka motion as data

This library does not do much on its own. What it does do, however, is enable the expression of
motion as data.

This library encourages you to describe motion as data, or what we call *plans*. Plans are committed
to a *scheduler*. The scheduler then coordinates the creation of *performers*, objects responsible
for translating plans into concrete execution.

## Installation

### Installation with CocoaPods

Add `MaterialMotionRuntime` to your `Podfile`:

    pod 'MaterialMotionRuntime'

Then run the following command:

    pod install

## Example apps/unit tests

To check out a local copy of the repo and run our example apps you can run the following commands:

    git clone https://github.com/material-motion/material-motion-runtime-objc.git
    cd material-motion-runtime-objc
    pod install
    open MaterialMotionRuntime.xcworkspace

## Contributing

We welcome contributions!

Check out our [upcoming milestones](https://github.com/material-motion/material-motion-runtime-objc/milestones).

Learn more about [our team](https://material-motion.gitbooks.io/material-motion-team/content/),
[our community](https://material-motion.gitbooks.io/material-motion-team/content/community/), and
our [contributor essentials](https://material-motion.gitbooks.io/material-motion-team/content/essentials/).

## License

Licensed under the Apache 2.0 license. See LICENSE for details.
