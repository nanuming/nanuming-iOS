//
//  EntryView.swift
//  Nanuming
//
//  Created by 가은 on 1/28/24.
//
import Foundation
import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

var screenWidth = UIScreen.main.bounds.size.width
var screenHeight = UIScreen.main.bounds.size.height

struct EntryView: View {
    
    @State private var isLogined = false
    @State private var userData :UserData
    @State private var isAlert = false
    @State private var message = ""
    @State private var nextView: Int = 1
    @State private var isSignInSuccessful = false
    
    public init(isLogined: Bool = false, userData: UserData) {
        _isLogined = State(initialValue:  isLogined)
        _userData = State(initialValue:  userData)
        let appearance = UINavigationBarAppearance()
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.textBlack]
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.textBlack]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .frame(width: screenWidth * 0.7,height: screenWidth * 0.65)
            ZStack {
                GoogleSignInButton(
                    scheme: .light,
                    style: .wide,
                    action: {
                        googleLogin { success in
                            if success {
                                let requestData = ["idToken": self.userData.IDToken]
                                //                                    print("idToken: \(self.userData.IDToken)")
                                signIn(requestData: requestData) { success, message in
                                    self.message = message
                                    if success {
                                        nextView = 1
                                        print("nextView 1: \(nextView)")
                                        isSignInSuccessful = success
                                        print("success: \(success), message: \(message)")
                                    } else {
                                        nextView = 2
                                        print("nextView 2: \(nextView)")
                                        isSignInSuccessful = true
                                        print("success: \(success), message: \(message)")
                                    }
                                }
                            } else {
                                self.isAlert = true
                            }
                        }
                    }
                )
                
                .frame(width: screenWidth*0.85, height: 50, alignment: .center)
            }
        }
        .onAppear(perform: {
            // login 상태 체크
            //            checkState()
        })
        .alert(LocalizedStringKey("Failed Login"), isPresented: $isAlert) {
            Button(action: {
                isAlert = false
            }, label: {
                Text("OK")
            })
        } message: {
            Text("please try again.")
        }
        .fullScreenCover(isPresented: $isSignInSuccessful) {
            if nextView == 1 {
                TabBarView()
            } else if nextView == 2 {
                JoinView(userData: $userData)
            }
        }
        .onChange(of: nextView, initial: false) { newValue, _ in
            if newValue == 1 {
                print("tabBarView")
            } else if newValue == 2 {
                print("JoinView")
            }
        }
    }
    func signIn(requestData: [String: Any], completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: []) else {
            completion(false, "Invalid request data")
            return
        }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                completion(false, "Network request failed")
                return
            }
            if let dataString = String(data: data, encoding: .utf8) {
                print("Response: \(dataString)")
            }
            do {
                let response = try JSONDecoder().decode(ApiResponse.self, from: data)
                if response.success {
                    completion(true, "Login successful")
                } else {
                    completion(false, response.message)
                }
            } catch {
                completion(false, "Failed to decode response: \(error.localizedDescription)")
            }
        }.resume()
    }
    func checkState() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                print("Not sign in")
            } else {
                guard let profile = user?.profile else { return }
                guard let idToken = user?.idToken else {
                    print("ID 토큰을 얻을 수 없습니다.")
                    return
                }
                let data = UserData(email: profile.email, IDToken: idToken.tokenString, picture: profile.imageURL(withDimension: 180))
                userData = data
                isLogined = true
                print("checkState: \(isLogined)")
                print("userData: \(data)")
            }
        }
    }
    func googleLogin(completion: @escaping (Bool) -> Void) {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController.self else {
            completion(false)
            return
        }
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { user, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let user = user, let profile = user.user.profile, let idToken = user.user.idToken else {
                print("ID 토큰을 얻을 수 없습니다.")
                completion(false)
                return
            }
            
            let data = UserData(email: profile.email, IDToken: idToken.tokenString, picture: profile.imageURL(withDimension: 180))
            self.userData = data
            self.isLogined = true
            completion(true)
        }
    }
    
    #Preview {
        EntryView(userData: UserData(email: "", IDToken: "", picture: nil))
    }
}
