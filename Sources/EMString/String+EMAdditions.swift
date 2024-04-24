//
//  NSString+EMAdditions.m
//  EMString
//
//  Created by Tanguy Aladenise on 2014-11-27.
//  Copyright (c) 2014 Tanguy Aladenise. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    var attributedString: NSAttributedString? {
        let markedUpString = EMMarkupProperty.EMDefaultMarkup.appending(self).appending(EMMarkupProperty.EMDefaultCloseMarkup)

        var string = NSAttributedString(string: styleParagraphForString(markedUpString))

        // Default style need to be applied first
        string = defaultStyling(string)
        string = styleStrong(string)
        string = styleEmphasis(string)
        string = styleUnderline(string)
        string = styleStrikethrough(string)
        string = styleHeaders(string)

        if EMStringStylingConfiguration.sharedInstance.stylingClasses.count > 0 {
            for stylingClass in EMStringStylingConfiguration.sharedInstance.stylingClasses {
                string = applyStylingClass(stylingClass, for: string)
            }
        }

        return string
    }

    private func styleParagraphForString(_ string: String) -> String {
        // In the string remove paragraph opening markup
        var styledString = clearMarkup(EMMarkupProperty.EMParagraphMarkup, for: string)
        // Then replace closing paragraph markup with a return to line
        styledString = styledString.replacingOccurrences(of: EMMarkupProperty.EMParagraphCloseMarkup, with: "\n")
        // Finally check for empty spaces at beginning of paragraph
        styledString = styledString.replacingOccurrences(of: "\n ", with: "\n")

        return styledString
    }

    private func clearMarkup(_ markup: String, for string: String) -> String {
        string.replacingOccurrences(of: markup, with: "")
    }

    private func defaultStyling(_ attributedString: NSAttributedString) -> NSAttributedString {
        let stylingClass = EMStylingClass(markup: EMMarkupProperty.EMDefaultMarkup)
        stylingClass.attributes = [
            .font: EMStringStylingConfiguration.sharedInstance.defaultFont,
            .foregroundColor: EMStringStylingConfiguration.sharedInstance.defaultColor,
        ]

        return applyStylingClass(stylingClass, for: attributedString)
    }

    private func styleStrong(_ attributedString: NSAttributedString) -> NSAttributedString {
        let stylingClass = EMStylingClass(markup: EMMarkupProperty.EMStrongMarkup)
        stylingClass.attributes = [
            .font: EMStringStylingConfiguration.sharedInstance.strongFont,
            .foregroundColor: EMStringStylingConfiguration.sharedInstance.strongColor,
        ]

        return applyStylingClass(stylingClass, for: attributedString)
    }

    private func styleEmphasis(_ attributedString: NSAttributedString) -> NSAttributedString {
        let stylingClass = EMStylingClass(markup: EMMarkupProperty.EMEmphasisMarkup)
        stylingClass.attributes = [
            .font: EMStringStylingConfiguration.sharedInstance.emphasisFont,
            .foregroundColor: EMStringStylingConfiguration.sharedInstance.emphasisColor,
        ]

        return applyStylingClass(stylingClass, for: attributedString)
    }

    private func styleUnderline(_ attributedString: NSAttributedString) -> NSAttributedString {
        let stylingClass = EMStylingClass(markup: EMMarkupProperty.EMUnderlineMarkup)
        stylingClass.attributes = [
            .underlineStyle: EMStringStylingConfiguration.sharedInstance.underlineStyle
        ]

        return applyStylingClass(stylingClass, for: attributedString)
    }

    private func styleStrikethrough(_ attributedString: NSAttributedString) -> NSAttributedString {
        let stylingClass = EMStylingClass(markup: EMMarkupProperty.EMStrikethroughMarkup)
        stylingClass.attributes = [
            .strikethroughStyle: EMStringStylingConfiguration.sharedInstance.striketroughStyle
        ]

        return applyStylingClass(stylingClass, for: attributedString)
    }

    private func applyStylingClass(_ stylingClass: EMStylingClass, for attributedString: NSAttributedString) -> NSAttributedString {
        // Use a mutable attributed string to apply styling by occurrence of markup
        let styleAttributedString = NSMutableAttributedString(attributedString: attributedString)

        var openMarkupRange = styleAttributedString.mutableString.range(of: stylingClass.markup)

        // Find range of open markup
        while openMarkupRange.location != NSNotFound {

            // Find range of close markup
            var closeMarkupRange = styleAttributedString.mutableString.range(of: stylingClass.closeMarkup)
            guard closeMarkupRange.location != NSNotFound else {
                print("Error finding close markup \(stylingClass.closeMarkup). Make sure you open and close your markups correctly.")
                return attributedString
            }

            // Calculate the style range that represents the string between the open and close markups
            let styleRange = NSRange(location: openMarkupRange.location, length: closeMarkupRange.location + closeMarkupRange.length - openMarkupRange.location)

            // Before applying style to the markup, make sure there is "sub" style that has been applied before.
            var restoreStyle = [[String: Any]]()

            styleAttributedString.enumerateAttributes(in: styleRange, options: .longestEffectiveRangeNotRequired) { attrs, range, _ in
                if !attrs.isEmpty {
                    if range.length < styleRange.length {
                        restoreStyle.append(["range": NSValue(range: range), "attrs": attrs])
                    }
                }
            }

            var overrideMarkup = false

            // Apply style to markup

            // Check if one of the custom class is not overriding a default markup with a more complex styling
            for aStylingClass in EMStringStylingConfiguration.sharedInstance.stylingClasses {
                if aStylingClass.markup == stylingClass.markup {
                    overrideMarkup = true
                    styleAttributedString.addAttributes(aStylingClass.attributes, range: styleRange)
                }
            }

            if !overrideMarkup {
                styleAttributedString.addAttributes(stylingClass.attributes, range: styleRange)
            }

            // Restore "sub" style if necessary
            for style in restoreStyle {
                guard let rangeValue = style["range"] as? NSRange, let attrs = style["attrs"] as? [NSAttributedString.Key: Any] else { continue }

                styleAttributedString.addAttributes(attrs, range: rangeValue)

                // When restoring sub style, make sure the color/font of the new style is not overridden by the default color/font because of the restoring mechanism.

                // First check if we are trying to apply a color to see if treatment is necessary
                if let foregroundColor = stylingClass.attributes[.foregroundColor] as? UIColor {
                    // If we apply a color make sure we did not just reapply the default color on that sub style.
                    if let attributes = style["attrs"] as? [NSAttributedString.Key: Any], let restoredForegroundColor = attributes[.foregroundColor] as? UIColor, restoredForegroundColor == EMStringStylingConfiguration.sharedInstance.defaultColor {
                        // If we restored wrongly default color, we reapply custom color styling.
                        styleAttributedString.addAttribute(.foregroundColor, value: foregroundColor, range: rangeValue)
                    }
                }

                // Same thing for font
                if let font = stylingClass.attributes[.font] as? UIFont {
                    if let attributes = style["attrs"] as? [NSAttributedString.Key: Any], let restoredFont = attributes[.font] as? UIFont, restoredFont == EMStringStylingConfiguration.sharedInstance.defaultFont {
                        styleAttributedString.addAttribute(.font, value: font, range: rangeValue)
                    }
                }
            }

            // Remove opening markup in string
            styleAttributedString.mutableString.replaceCharacters(in: NSRange(location: openMarkupRange.location, length: openMarkupRange.length), with: "")

            // Refind range of closing markup because it moved since we removed opening markup
            closeMarkupRange = styleAttributedString.mutableString.range(of: stylingClass.closeMarkup)

            // Remove closing markup in string
            var replaceEndMarkupBy = ""
            if closeMarkupRange.location != NSNotFound, closeMarkupRange.location < styleAttributedString.string.count - stylingClass.closeMarkup.count && stylingClass.displayBlock {
                replaceEndMarkupBy = "\n"
            }
            styleAttributedString.mutableString.replaceCharacters(in: NSRange(location: closeMarkupRange.location, length: closeMarkupRange.length), with: replaceEndMarkupBy)


            openMarkupRange = styleAttributedString.mutableString.range(of: stylingClass.markup)
        }

        return styleAttributedString
    }


    private func styleHeaders(_ attributedString: NSAttributedString) -> NSAttributedString {
        var mutableAttributedString = attributedString

        var stylingClass = EMStylingClass(markup: EMMarkupProperty.EMH1Markup)
        stylingClass.attributes = [
            .font: EMStringStylingConfiguration.sharedInstance.h1Font,
            .foregroundColor: EMStringStylingConfiguration.sharedInstance.h1Color
        ]
        stylingClass.displayBlock = !EMStringStylingConfiguration.sharedInstance.h1DisplayInline
        mutableAttributedString = applyStylingClass(stylingClass, for: mutableAttributedString)

        stylingClass = EMStylingClass(markup: EMMarkupProperty.EMH2Markup)
        stylingClass.attributes = [
            .font: EMStringStylingConfiguration.sharedInstance.h2Font,
            .foregroundColor: EMStringStylingConfiguration.sharedInstance.h2Color
        ]

        stylingClass.displayBlock = !EMStringStylingConfiguration.sharedInstance.h2DisplayInline
        mutableAttributedString = applyStylingClass(stylingClass, for: mutableAttributedString)

        stylingClass = EMStylingClass(markup: EMMarkupProperty.EMH3Markup)
        stylingClass.attributes = [
            .font: EMStringStylingConfiguration.sharedInstance.h3Font,
            .foregroundColor: EMStringStylingConfiguration.sharedInstance.h3Color
        ]
        stylingClass.displayBlock = !EMStringStylingConfiguration.sharedInstance.h3DisplayInline
        mutableAttributedString = applyStylingClass(stylingClass, for: mutableAttributedString)

        stylingClass = EMStylingClass(markup: EMMarkupProperty.EMH4Markup)
        stylingClass.attributes = [
            .font: EMStringStylingConfiguration.sharedInstance.h4Font,
            .foregroundColor: EMStringStylingConfiguration.sharedInstance.h4Color
        ]

        stylingClass.displayBlock = !EMStringStylingConfiguration.sharedInstance.h4DisplayInline
        mutableAttributedString = applyStylingClass(stylingClass, for: mutableAttributedString)

        stylingClass = EMStylingClass(markup: EMMarkupProperty.EMH5Markup)
        stylingClass.attributes = [
            .font: EMStringStylingConfiguration.sharedInstance.h5Font,
            .foregroundColor: EMStringStylingConfiguration.sharedInstance.h5Color
        ]
        stylingClass.displayBlock = !EMStringStylingConfiguration.sharedInstance.h5DisplayInline
        mutableAttributedString = applyStylingClass(stylingClass, for: mutableAttributedString)

        stylingClass = EMStylingClass(markup: EMMarkupProperty.EMH6Markup)
        stylingClass.attributes = [
            .font: EMStringStylingConfiguration.sharedInstance.h6Font,
            .foregroundColor: EMStringStylingConfiguration.sharedInstance.h6Color
        ]

        stylingClass.displayBlock = !EMStringStylingConfiguration.sharedInstance.h6DisplayInline
        mutableAttributedString = applyStylingClass(stylingClass, for: mutableAttributedString)
        
        return attributedString

    }
}


