//
//  Extensions.swift
//  ilegal
//
//  Created by Matthew Rigdon on 3/7/17.
//  Copyright © 2017 Jordan. All rights reserved.
//

import UIKit

extension String {
    var slug: String {
        return self.lowercased().replacingOccurrences(of: " ", with: "_")
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}
