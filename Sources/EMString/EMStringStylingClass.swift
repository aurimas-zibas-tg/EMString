//
//  EMStylingClass.m
//  EMString
//
//  Created by Tanguy Aladenise on 2014-12-04.
//  Copyright (c) 2014 Tanguy Aladenise. All rights reserved.
//

import Foundation
import UIKit

public class EMStylingClass {

    public let markup: String
    public var name: String?
    public var displayBlock: Bool = false
    public var attributes: [NSAttributedString.Key: Any] {
        get {
            mutableAttributes
        } set {
            mutableAttributes.merge(newValue, uniquingKeysWith: { _, new in new })
        }
    }
    public var closeMarkup: String {
        markup.replacingOccurrences(of: "<", with: "</")
    }
    public var color: UIColor? {
        didSet {
            guard let color = color else { return }
            mutableAttributes[.foregroundColor] = color
        }
    }
    public var font: UIFont? {
        didSet {
            guard let font = font else { return }
            mutableAttributes[.font] = font
        }
    }

    private var mutableAttributes: [NSAttributedString.Key: Any] = [:]

    public init(markup: String) {
        self.markup = markup
    }

}
