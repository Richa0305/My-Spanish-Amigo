//
//  DesignableView.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 06/06/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import UIKit

@IBDesignable class DesignableView: UIView {

    @IBInspectable var cornorRadious: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornorRadious
        }
    }

}
