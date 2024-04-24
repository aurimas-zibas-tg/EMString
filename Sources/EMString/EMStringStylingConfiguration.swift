//
//  EMStringStyling.m
//  EMString
//
//  Created by Tanguy Aladenise on 2014-11-27.
//  Copyright (c) 2014 Tanguy Aladenise. All rights reserved.
//

import UIKit

import Foundation
import UIKit

public class EMStringStylingConfiguration {
    public static let sharedInstance = EMStringStylingConfiguration()

    private var mutableStylingClasses: [EMStylingClass] = []

    public func addNewStylingClass(_ stylingClass: EMStylingClass) {
        if stylingClasses.contains(stylingClass) {
            print("Class already added")
            return
        }

        mutableStylingClasses.append(stylingClass)
    }

    public var stylingClasses: [EMStylingClass] {
        mutableStylingClasses
    }

    // Fonts

    public var defaultFont: UIFont {
        get {
            _defaultFont ?? UIFont.systemFont(ofSize: 16)
        }
        set {
            _defaultFont = newValue
        }
    }


    public var strongFont: UIFont {
        get {
            _strongFont ??
            findFontByAppendingStyle("Bold") ??
            UIFont.boldSystemFont(ofSize: defaultFont.pointSize)
        }
        set {
            _strongFont = newValue
        }
    }

    public var emphasisFont: UIFont {
        get {
            _emphasisFont ??
            findFontByAppendingStyle("Italic") ??
            UIFont.italicSystemFont(ofSize: defaultFont.pointSize)
        }
        set {
            _emphasisFont = newValue
        }
    }

    public var h1Font: UIFont {
        get {
            _h1Font ??
            UIFont(name: defaultFont.familyName, size: defaultFont.pointSize + 18) ??
            UIFont.systemFont(ofSize: defaultFont.pointSize + 18)
        }
        set {
            _h1Font = newValue
        }
    }

    public var h2Font: UIFont {
        get {
            _h2Font ??
            UIFont(name: defaultFont.familyName, size: defaultFont.pointSize + 15) ??
            UIFont.systemFont(ofSize: defaultFont.pointSize + 15)
        }
        set {
            _h2Font = newValue
        }
    }

    public var h3Font: UIFont {
        get {
            _h3Font ??
            UIFont(name: defaultFont.familyName, size: defaultFont.pointSize + 12) ??
            UIFont.systemFont(ofSize: defaultFont.pointSize + 12)
        }
        set {
            _h3Font = newValue
        }
    }

    public var h4Font: UIFont {
        get {
            _h4Font ??
            UIFont(name: defaultFont.familyName, size: defaultFont.pointSize + 9) ??
            UIFont.systemFont(ofSize: defaultFont.pointSize + 9)
        }
        set {
            _h4Font = newValue
        }
    }

    public var h5Font: UIFont {
        get {
            _h5Font ??
            UIFont(name: defaultFont.familyName, size: defaultFont.pointSize + 6) ??
            UIFont.systemFont(ofSize: defaultFont.pointSize + 6)
        }
        set {
            _h5Font = newValue
        }
    }

    public var h6Font: UIFont {
        get {
            _h6Font ??
            UIFont(name: defaultFont.familyName, size: defaultFont.pointSize + 3) ??
            UIFont.systemFont(ofSize: defaultFont.pointSize + 3)
        }
        set {
            _h6Font = newValue
        }
    }

    private func findFontByAppendingStyle(_ style: String) -> UIFont? {
        guard !useDefaultSystemFont() else { return nil }

        let styleFontName = "\(defaultFont.familyName)-\(style.capitalized)"
        var font = UIFont(name: styleFontName, size: defaultFont.pointSize)

        if font == nil {
            font = UIFont(name: styleFontName + "MT", size: defaultFont.pointSize)
        }

        if font == nil {
            print("EMString was not able to find a font \(style) automatically for your custom default font : \(defaultFont.familyName). The system default font for \(style) will be used instead.")
        }

        return font
    }

    private func useDefaultSystemFont() -> Bool {
        return defaultFont.familyName == UIFont.systemFont(ofSize: 16).familyName
    }

    // Colors

    public var defaultColor: UIColor {
        get {
            _defaultColor ?? UIColor.black
        }
        set {
            _defaultColor = newValue
        }
    }

    public var strongColor: UIColor {
        get {
            _strongColor ?? defaultColor
        }
        set {
            _strongColor = newValue
        }
    }

    public var emphasisColor: UIColor {
        get {
            _emphasisColor ?? defaultColor
        }
        set {
            _emphasisColor = newValue
        }
    }

    public var h1Color: UIColor {
        get {
            _h1Color ?? defaultColor
        }
        set {
            _h1Color = newValue
        }
    }

    public var h2Color: UIColor {
        get {
            _h2Color ?? defaultColor
        }
        set {
            _h2Color = newValue
        }
    }

    public var h3Color: UIColor {
        get {
            _h3Color ?? defaultColor
        }
        set {
            _h3Color = newValue
        }
    }

    public var h4Color: UIColor {
        get {
            _h4Color ?? defaultColor
        }
        set {
            _h4Color = newValue
        }
    }

    public var h5Color: UIColor {
        get {
            _h5Color ?? defaultColor
        }
        set {
            _h5Color = newValue
        }
    }

    public var h6Color: UIColor {
        get {
            _h6Color ?? defaultColor
        }
        set {
            _h6Color = newValue
        }
    }

    // Options

    public var underlineStyle: NSUnderlineStyle {
        _underlineStyle ?? .single
    }

    public var striketroughStyle: NSUnderlineStyle {
        _striketroughStyle ?? .single
    }

    public var h1DisplayInline = false
    public var h2DisplayInline = false
    public var h3DisplayInline = false
    public var h4DisplayInline = false
    public var h5DisplayInline = false
    public var h6DisplayInline = false

    private var _defaultFont: UIFont?
    private var _defaultColor: UIColor?
    private var _strongFont: UIFont?
    private var _strongColor: UIColor?
    private var _emphasisFont: UIFont?
    private var _emphasisColor: UIColor?
    private var _h1Font: UIFont?
    private var _h1Color: UIColor?
    private var _h2Font: UIFont?
    private var _h2Color: UIColor?
    private var _h3Font: UIFont?
    private var _h3Color: UIColor?
    private var _h4Font: UIFont?
    private var _h4Color: UIColor?
    private var _h5Font: UIFont?
    private var _h5Color: UIColor?
    private var _h6Font: UIFont?
    private var _h6Color: UIColor?
    private var _underlineStyle: NSUnderlineStyle = .single
    private var _striketroughStyle: NSUnderlineStyle = .single
}

extension EMStylingClass: Equatable {

    public static func == (lhs: EMStylingClass, rhs: EMStylingClass) -> Bool {
        return lhs.markup == rhs.markup
    }
}
