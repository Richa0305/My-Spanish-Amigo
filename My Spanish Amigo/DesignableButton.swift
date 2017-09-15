//
//  DesignableButton.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 06/06/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import UIKit

class DesignableButton: UIButton {

 
    
    @IBInspectable var cornorRadious: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornorRadious
        }
    }
    
    
    @IBInspectable var borderWidth : CGFloat = 0.0{
        didSet{
            self.layer.borderWidth = borderWidth
            
        }
    }
    
    @IBInspectable var borderColor : UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }

}
