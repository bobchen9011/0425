////
////  Verfication.swift
////  project0622
////
////  Created by bbob on 2023/9/19.
////
//
//import SwiftUI
//
//struct Verfication: View {
//    @ObservedObject var loginData : LoginViewModel
//    @Environment(\.presentationMode) var present
//    @AppStorage("log_Status") var status = false
//    var body: some View {
//        ZStack{
//            VStack {
//                VStack {
//                    HStack {
//                        Button(action: {
//                            present.wrappedValue.dismiss()
//                        }) {
//                            Image(systemName: "arrow.left")
//                                .font(.title2)
//                                .foregroundColor(.black)
//                        }
//                        Spacer()
//                        
//                        Text("Verify Phone")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                            .foregroundColor(.black)
//                        Spacer()
//                        
//                        if loginData.loading{ProgressView()}
//                    }
//                    .padding()
//                    
//                    Text("Code sent to \(loginData.phNo)")
//                        .foregroundColor(.gray)
//                        .padding(.bottom)
//                    
//                    Spacer(minLength: 0)
//                    
//                    HStack(spacing: 15){
//                        ForEach(0..<6,id: \.self) {index in
//                            CodeView(code: getCodeAtIndex(index: index))
//                        }
//                    }
//                    .padding()
//                    .padding(.horizontal,20)
//                    
//                    Spacer(minLength: 0)
//                    
//                    HStack(spacing: 6) {
//                        Text("沒收到驗證碼")
//                            .foregroundColor(.gray)
//                        
//                        Button(action: loginData.requestCode) {
//                            Text("Request Again")
//                                .fontWeight(.bold)
//                                .foregroundColor(.black)
//                        }
//                    }
//                    Button(action: loginData.verifyCode) {
//                        Text("get via call")
//                            .fontWeight(.bold)
//                            .foregroundColor(.black)
//                    }
//                    .padding(.top,6)
//                    
//                    Button(action: loginData.verifyCode) {
//                        Text("驗證和創建帳號")
//                            .foregroundColor(.black)
//                            .padding(.vertical)
//                            .frame(width: UIScreen.main.bounds.width-30)
//                            .background(Color.yellow)
//                            .cornerRadius(15)
//                    }
//                }
//                .frame(height: UIScreen.main.bounds.height / 1.8)
//                .background(Color.white)
//                .cornerRadius(20)
//                
//                CustomNumberPad(value: $loginData.code, isVerify: true)
//
//            }
//            .background(Color("bg").ignoresSafeArea(.all, edges: .bottom))
//            
//            if loginData.error {
//                AlertView(msg: loginData.errorMsg, show: $loginData.error)
//            }
//            
//        }
//        .navigationBarHidden(true)
//        .navigationBarBackButtonHidden(true)
//    }
//    
//    func getCodeAtIndex(index: Int)->String {
//        if loginData.code.count > index{
//            let start = loginData.code.startIndex
//            
//            let current = loginData.code.index(start, offsetBy: index)
//            
//            return String(loginData.code[current])
//        }
//        return ""
//    }
//}
//
//struct CodeView: View {
//    var code: String
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            Text(code)
//                .foregroundColor(.black)
//                .fontWeight(.bold)
//                .font(.title2)
//                .frame(height: 45)
//            
//            Capsule()
//                .fill(Color.gray.opacity(0.5))
//                .frame(height: 4)
//        }
//    }
//}
