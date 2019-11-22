//
//  ViewController.swift
//  Combine_Swift_Demo
//
//  Created by Vikhyath on 14/11/19.
//  Copyright © 2019 Vikhyath. All rights reserved.
//

import UIKit
import Combine

struct Form {
    
    let imageName: String
    let placeHolder: String
    let isSecuredTextEntry: Bool
    
}

class FormVM: NSObject {
    
    @Published var userName: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
        
    var completion: ((Bool) -> Void)?
    var form: [Form] = []
    
    var isValid: Bool = false {
        
        didSet {
            completion?(isValid)
        }
    }

    var validatedValue1: AnyPublisher<String?, Never> {
        return $userName.map { value1 in
            guard value1.count > 2 else {
                // change imageview tint color to red
                return nil
            }
            DispatchQueue.main.async {
                // change tint color to green
                
            }
            return value1
        }.eraseToAnyPublisher()
    }

    var validatedValue2: AnyPublisher<String?, Never> {
        return Publishers.CombineLatest($password, $confirmPassword)
            .receive(on: RunLoop.main)
            .map { value2, value2_repeat in
                guard value2_repeat == value2, value2.count > 4 else {
                    // red
                    return nil
                }
                // green
                return value2
            }.eraseToAnyPublisher()
    }

    var readyToSubmit: AnyPublisher<(String, String)?, Never> {
        return Publishers.CombineLatest(validatedValue2, validatedValue1)
            .map { value2, value1 in
                guard let realValue2 = value2, let realValue1 = value1 else {
                    return nil
                }
                return (realValue2, realValue1)
            }
            .eraseToAnyPublisher()
    }
    
    func getFormDetails() {
        
        form.append(Form(imageName: "icons8-password-100", placeHolder: "Username", isSecuredTextEntry: false))
        form.append(Form(imageName: "icons8-password-100", placeHolder: "Password", isSecuredTextEntry: true))
        form.append(Form(imageName: "icons8-password-100", placeHolder: "Confirm Password", isSecuredTextEntry: true))
    }
    
    func validateFields() {
        
    }
}


extension FormVM: CombineTextFieldDelegate {
    
    func combineTextFieldDidBeginEditing(_ textField: CombineTextField, with type: CombineTextFieldType) {
        print(type)
        let text = textField.textField.text ?? ""
        switch type {
        case .userName:
            userName = text
        case .password:
            password = text
        case .confirmPassword:
            confirmPassword = text
        }
    }
    
}

class ViewController: UIViewController {

    @IBOutlet weak var userNameView: CombineTextField!
    @IBOutlet weak var passwordField: CombineTextField!
    @IBOutlet weak var confirmPassWordField: CombineTextField!
    @IBOutlet weak var doneButton: UIButton!
    
    var userName = CombineTextField()
    var password = CombineTextField()
    var confirmPassword = CombineTextField()
    private var cancellableSet: Set<AnyCancellable> = []
    
    var isEnabled = false {
        
        didSet {
            doneButton.alpha = isEnabled ? 1 : 0.3
            doneButton.isEnabled = isEnabled
        }
    }
    
    let formDetails = FormVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formDetails.getFormDetails()
        
        userName = CombineTextField.instanceFromNib() as? CombineTextField ?? CombineTextField()
        password = CombineTextField.instanceFromNib() as? CombineTextField ?? CombineTextField()
        confirmPassword = CombineTextField.instanceFromNib() as? CombineTextField ?? CombineTextField()
        
        userNameView.addSubview(userName)
        passwordField.addSubview(password)
        confirmPassWordField.addSubview(confirmPassword)
        
        userName.frame = userNameView.bounds
        password.frame = passwordField.bounds
        confirmPassword.frame = confirmPassWordField.bounds
        
        userName.delegate = formDetails
        password.delegate = formDetails
        confirmPassword.delegate = formDetails
        
        userName.type = .userName
        password.type = .password
        confirmPassword.type = .confirmPassword
        
        setUpviews()
        formDetails.completion = { isValid in
            
            self.doneButton.isEnabled = isValid
            self.doneButton.alpha = isValid ? 1 : 0.3
            self.doneButton.isEnabled = isValid
        }
        
        formDetails.readyToSubmit
        .map { $0 != nil }
        .receive(on: RunLoop.main)
        .assign(to: \.isValid, on: formDetails)
        .store(in: &cancellableSet)
    }
    
    func setUpviews() {
        
        userName.initialsetup(form: formDetails.form[0])
        password.initialsetup(form: formDetails.form[1])
        confirmPassword.initialsetup(form: formDetails.form[2])
    }
}

extension UIView {
    class func instanceFromNib() -> UIView? {
        return UINib(nibName: String(describing: self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}



