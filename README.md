# ClapsView 👏
Implemented the functionality of [Medium.com Claps](https://blog.medium.com/show-authors-more-%EF%B8%8F-with-s-c1652279ba01).

[![Build Status](https://travis-ci.org/hemangshah/ClapsView.svg?branch=master)](https://travis-ci.org/hemangshah/ClapsView)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)
![Platform](https://img.shields.io/badge/Platforms-iOS-red.svg)
![Swift 4.x](https://img.shields.io/badge/Swift-4.x-blue.svg)
![MadeWithLove](https://img.shields.io/badge/Made%20with%20%E2%9D%A4-India-green.svg)
[![Blog](https://img.shields.io/badge/Blog-iKiwiTech.com-blue.svg)](http://www.ikiwitech.com)

1. [Screenshots](#screenshots)
2. [Features](#features)
3. [Installation](#installation)
4. [Usage Guide](#usage-guide)
5. [Setup](#setup)
6. [ToDos](#todos)
7. [Credits](#credits)
8. [Thanks](#thank-you)
9. [License](#license)

## Screenshots

<table>
<tr>
<td align="center"><img src = "https://github.com/hemangshah/ClapsView/blob/master/Screenshots/Screenshot-1.png" alt = "Usage"></td>
<td align="center"><img src = "https://github.com/hemangshah/ClapsView/blob/master/Screenshots/Screenshot-2.png" alt = "Usage"></td>
</tr>
<tr>
<td align="center" colspan="3"><img src = "https://github.com/hemangshah/ClapsView/blob/master/Screenshots/ClapsViewUsage.gif" alt = "Usage"></td>
</tr>
</table>

## Features

1. Create Programmatically or in Storyboard.
2. Dynamic Property Configurations.
3. Replica of Medium.com's Claps.
7. Lightweight with zero dependancies.

## Installation

1. **Storyboard** – Add a `UIView` and change the class in Identity Inspector to `ClapsView`.<br>
2. **Manually** – Add `ClapsView.swift` file to your Project.<br>
3. **CocoaPods** – `pod 'ClapsView'`
    
> You can read the [CHANGELOG](https://github.com/hemangshah/ClapsView/blob/master/CHANGELOG.md) file for a particular release.

## Usage Guide

- Long Press – To start clapping. 👏
- Double Tap - To remove current claps.
- Single Tap - To see current Claps.

## Setup

````
let claps = ClapsView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 100.0, height: 100.0)))
claps.delegate = self
//Customize Emoji.
claps.emoji = "👏"
//The number of claps by all of the user.
claps.totalClaps = 30
//The maximum number of claps a user can do.
claps.maxClaps = 50
//If set true, 1000 claps will be display as 1k
claps.showClapsAbbreviated = true
self.view.addSubview(claps)
claps.center = self.view.center

//Implementing Delegate Call
extension ViewController: ClapsViewDelegate {
    func clapsViewStateChanged(clapsView: ClapsView, state: ClapsViewStates, totalClaps: Int, currentClaps: Int) {
        if state == .finalized {
            print("ClapsViewTag: \(clapsView.tag) | Total Claps:\(totalClaps) | Current Claps:\(currentClaps)")
        }
    }
}
````

## ToDo[s]

- [ ] CocoaPods Support

You can [watch](https://github.com/hemangshah/ClapsView/subscription) to <b>ClapsView</b> to see continuous updates. Stay tuned.

<b>Have an idea for improvements of this class?
Please open an [issue](https://github.com/hemangshah/ClapsView/issues/new).</b>
    
## Credits

<b>[Hemang Shah](https://about.me/hemang.shah)</b>

**You can shoot me an [email](http://www.google.com/recaptcha/mailhide/d?k=01IzGihUsyfigse2G9z80rBw==&c=vU7vyAaau8BctOAIJFwHVbKfgtIqQ4QLJaL73yhnB3k=) to contact.**
   
## Thank You!!

See the [contributions](https://github.com/hemangshah/ClapsView/blob/master/CONTRIBUTIONS.md) for details.

## License

The MIT License (MIT)

> Read the [LICENSE](https://github.com/hemangshah/ClapsView/blob/master/LICENSE) file for details.
