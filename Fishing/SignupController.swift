//
//  SignupController.swift
//  Fishing
//
//  Created by John Nik on 27/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import KRProgressHUD

class SignupController: UIViewController {
    
    let reachAbility = Reachability()!
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.close.rawValue)?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDismissController), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign up"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }()
    
    let emailTextField: ToplessTextField = {
        let textField = ToplessTextField()
        let str = NSAttributedString(string: "Email Address", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textField.attributedPlaceholder = str
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .white
        
        return textField
    }()
    
    let passwordTextField: ToplessTextField = {
        let textField = ToplessTextField()
        let str = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textField.attributedPlaceholder = str
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .white
        
        return textField
    }()
    
    lazy var signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.setTitleColor(StyleGuideManager.signinButtonColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}



//MARK: handle sign up, dismiss
extension SignupController {
    
    @objc fileprivate func handleSignup() {
        
        self.view.endEditing(true)
        
        if reachAbility.connection == .none {
            self.showJHTAlerttOkayWithIcon(message: "The Internet connection appears to be offline.")
            return
        }
        
        if !(checkInvalid()) {
            return
        }
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        let requestStr = String(format: WebService.signUp.rawValue, email, password)
        guard let urlStr = requestStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
            return
        }
        guard let requestUrl = URL(string: urlStr) else {
            self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
            return
        }
        
        KRProgressHUD.show()
        
        URLSession.shared.dataTask(with: requestUrl) { (data, response, error) in
            
            if error != nil {
                print("error: ", error!)
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                }
                return
            }
            
            let jsonString = String(data: data, encoding: .utf8)
            print("json: ", jsonString ?? "")
            
            if jsonString == "\t\"Exists\"" {
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    
                    self.showJHTAlerttOkayWithIcon(message: "User already exists!")
                }
            } else {
                do {
                    let fishLegitUser = try JSONDecoder().decode(FishLegitUser.self, from: data)
                    print(fishLegitUser)
                    
                    DispatchQueue.main.async {
                        KRProgressHUD.dismiss()
                        
                        self.showJHTAlerttOkayWithIconForAction(message: "Success!\nPlease check your email for an activation link.", action: { (action) in
                            self.handleDismissController()
                        })
                    }
                    
                } catch let jsonErr {
                    print("Error serializing error: ", jsonErr)
                    DispatchQueue.main.async {
                        KRProgressHUD.dismiss()
                        self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                    }
                }
            }
        }.resume()
    }
    
    @objc fileprivate func handleDismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: check valid
extension SignupController {
    
    fileprivate func checkInvalid() -> Bool {
        
        if (emailTextField.text?.isEmptyStr)! || !self.isValidEmail(emailTextField.text!) {
            self.showJHTAlerttOkayWithIcon(message: "Invalid Email!\nPlease type valid Email")
            return false
        }
        
        if (passwordTextField.text?.isEmptyStr)! || !self.isValidPassword(passwordTextField.text!) {
            self.showJHTAlerttOkayWithIcon(message: "Invalid Password!\nPlease type Strong Password")
            return false
        }
        return true
    }
    
    fileprivate func isValidEmail(_ email: String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    fileprivate func isValidPassword(_ password: String) -> Bool {
        if password.count >= 5 {
            return true
        } else {
            return false
        }
    }
    
}

//MARK: setup views
extension SignupController {
    
    fileprivate func setupViews() {
        
        self.setupBackground()
        self.setupNavBar()
        self.setupSinupStuff()
    }
    
    private func setupNavBar() {
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        
        titleLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        
    }
    
    private func setupSinupStuff() {
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signupButton)
        
        emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: emailTextField.centerXAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10).isActive = true
        
        signupButton.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        signupButton.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        signupButton.centerXAnchor.constraint(equalTo: emailTextField.centerXAnchor).isActive = true
        signupButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20).isActive = true
        
        let thumbnailImageView = UIImageView()
        thumbnailImageView.image = UIImage(named: "thumbnail")
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(thumbnailImageView)
        thumbnailImageView.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.5).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.5).isActive = true
        thumbnailImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let height = (DEVICE_HEIGHT - CGFloat(240)) / 2
        thumbnailImageView.centerYAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: height).isActive = true
        
    }
    
    private func setupBackground() {
        navigationController?.isNavigationBarHidden = true
        
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundImageView)
        
        backgroundImageView.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH).isActive = true
        backgroundImageView.heightAnchor.constraint(equalToConstant: DEVICE_HEIGHT).isActive = true
        backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        
        
    }
    
}
