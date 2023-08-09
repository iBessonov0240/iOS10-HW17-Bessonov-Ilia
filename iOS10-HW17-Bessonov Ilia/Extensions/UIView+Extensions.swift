//
//  UIView+Extensions.swift
//  iOS10-HW17-Bessonov Ilia
//
//  Created by i0240 on 07.08.2023.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
}
