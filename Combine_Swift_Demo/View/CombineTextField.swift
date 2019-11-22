//
//  CombineTextField.swift
//  Combine_Swift_Demo
//
//  Created by Vikhyath on 14/11/19.
//  Copyright © 2019 Vikhyath. All rights reserved.
//

import UIKit

protocol CombineTextFieldDelegate: class {
    
    func combineTextFieldDidBeginEditing(_ textField: CombineTextField, with type: CombineTextFieldType)
}

enum CombineTextFieldType {
    case userName
    case password
    case confirmPassword
}

class CombineTextField: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: CustomTextField!
    var type: CombineTextFieldType = .userName
    
    weak var delegate: CombineTextFieldDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.layer.cornerRadius = 5
        textField.delegate = self
    }
    
    func initialsetup(form: Form) {
        
        imageView.image = UIImage(named: form.imageName)
        textField.attributedPlaceholder = NSAttributedString(string: form.placeHolder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .light)])
        textField.isSecureTextEntry = form.isSecuredTextEntry
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        delegate?.combineTextFieldDidBeginEditing(self, with: type)
    }
    
}

extension CombineTextField: UITextFieldDelegate {
    
}
