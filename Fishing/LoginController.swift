//
//  LoginController.swift
//  Fishing
//
//  Created by John Nik on 27/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import KRProgressHUD

class LoginController: UIViewController {
    
    let reachAbility = Reachability()!
    
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
    
    lazy var signinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in", for: .normal)
        button.setTitleColor(StyleGuideManager.signinButtonColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSignin), for: .touchUpInside)
        return button
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
        self.setupKeyboardObservers()
        self.setupViews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

//MARK: handle signup and signin
extension LoginController {
    
    @objc fileprivate func handleSignin() {
        self.view.endEditing(true)
        
        if reachAbility.connection == .none {
            self.showJHTAlerttOkayWithIcon(message: "The Internet connection appears to be offline.")
            return
        }
        
        if !(checkInvalid()) {
            return
        }
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        self.handleSigninWith(email: email, password: password)
        
    }
    
    private func finishLoggingInWithUser(_ user: FishLegitUser)  {
        let userDefaults = UserDefaults.standard
        userDefaults.setIsLoggedIn(value: true)
        if let userId = user.user_id {
            userDefaults.setUserId(userId)
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    fileprivate func handleSigninWith(email: String, password: String) {
        
        let requestStr = String(format: WebService.login.rawValue, email, password)
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
            
            let dataAsString = String(data: data, encoding: .utf8)
            print(dataAsString!)
            
            do {
                let fishLegitUser = try JSONDecoder().decode(FishLegitUser.self, from: data)
                print(fishLegitUser)
                
                let jsonString = String(data: data, encoding: .utf8)
                print("json: ", jsonString ?? "")
                
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    self.finishLoggingInWithUser(fishLegitUser)
                }
                
                
            } catch let jsonErr {
                print("Error serializing error: ", jsonErr)
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                }
            }
        }.resume()
        
    }
    
    @objc fileprivate func handleSignup() {
        
        let signupController = SignupController()
        self.present(signupController, animated: true, completion: nil)
        
    }
    
}

//MARK: check valid
extension LoginController {
    
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

//MARK: - handleKeyboard
extension LoginController {
    fileprivate func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.view.frame.origin.y = 0
            } else {
                self.view.frame.origin.y = -(endFrame?.size.height)!
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}


extension LoginController {
    
    fileprivate func setupViews() {
        
        self.setupBackground()
        self.setupSigninStuff()
    }
    
    private func setupSigninStuff() {
        
        //setup signin stuff
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signinButton)
        view.addSubview(signupButton)
        
        signupButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        signupButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signupButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.widthAnchor.constraint(equalTo: signupButton.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: signupButton.topAnchor, constant: -10).isActive = true
        
        let accountLabel = UILabel()
        accountLabel.text = "Don't have an account?"
        accountLabel.textAlignment = .center
        accountLabel.textColor = .white
        accountLabel.backgroundColor = .clear
        accountLabel.sizeToFit()
        accountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(accountLabel)
        
        accountLabel.widthAnchor.constraint(equalToConstant: 185).isActive = true
        accountLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        accountLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        accountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        let leftLineView = UIView()
        leftLineView.backgroundColor = .white
        leftLineView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(leftLineView)
        leftLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        leftLineView.rightAnchor.constraint(equalTo: accountLabel.leftAnchor).isActive = true
        leftLineView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        leftLineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        let rightLineview = UIView()
        rightLineview.backgroundColor = .white
        rightLineview.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(rightLineview)
        rightLineview.leftAnchor.constraint(equalTo: accountLabel.rightAnchor).isActive = true
        rightLineview.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        rightLineview.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        rightLineview.heightAnchor.constraint(equalToConstant: 2).isActive = true

        
        signinButton.widthAnchor.constraint(equalTo: signupButton.widthAnchor).isActive = true
        signinButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        signinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signinButton.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -10).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalTo: signupButton.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.bottomAnchor.constraint(equalTo: signinButton.topAnchor, constant: -20).isActive = true
        
        emailTextField.widthAnchor.constraint(equalTo: signupButton.widthAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -10).isActive = true
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
        
        
        let titleLabel = UILabel()
        titleLabel.text = "FishLegit"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 35)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
//        titleLabel.sizeToFit()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        
        let thumbnailImageView = UIImageView()
        thumbnailImageView.image = UIImage(named: "thumbnail")
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(thumbnailImageView)
        thumbnailImageView.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.5).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.5).isActive = true
        thumbnailImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        thumbnailImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
    }
    
}





















