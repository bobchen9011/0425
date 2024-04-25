//
//  firstView.swift
//  go
//
//  Created by Ping chi Chen on 2022/12/8.
//
//主畫面

import SwiftUI
import RiveRuntime

struct ContentView: View {
    @State private var isShowing = false
    @Environment(\.colorScheme) var currentColorScheme

    @State private var isDarkModeOn = false

    var body: some View {
        NavigationView {
            ZStack {
                if isShowing {
                    sideMenuView(isShowing: $isShowing)
                }
                HomeView(isDarkModeOn: $isDarkModeOn)
                    .cornerRadius(isShowing ? 20 : 10)
                    .offset(x: isShowing ? 300 : 0, y: isShowing ? 44 : 0)
                    .scaleEffect(isShowing ? 0.9 : 1)
                    .navigationBarItems(
                        leading: Button(action: {
                            withAnimation(.spring()) {
                                isShowing.toggle()
                            }
                        }) {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.black)
                        },
                        trailing: Button(action: {
                            isDarkModeOn.toggle()
                        }) {
                            Image(systemName: isDarkModeOn ? "sun.max.fill" : "moon.fill")
                                .foregroundColor(isDarkModeOn ? .white : .black)
                        }
                    )
                    .navigationTitle("首頁")
                    .navigationBarTitleDisplayMode(.inline)
                    .preferredColorScheme(isDarkModeOn ? .dark : .light) // Use isDarkModeOn to determine color scheme
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct HomeView: View {
    @Binding var isDarkModeOn: Bool

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            NavigationLink(destination: productSeclectView()) {
                Text("模組控制")
                    .customFont(.headline)
                    .padding(20)
                    .frame(width: 250, height: 200)
                    .background(Color(hex: "008080"))
                    .foregroundColor(.white)
                    .shadow(color: Color(hex: "00ffff").opacity(0.5), radius: 20, x: 0, y: 10)
                    .cornerRadius(20)
            }
            Spacer()
            NavigationLink(destination: experiView()) {
                Text("肌肉狀態紀錄")
                    .customFont(.headline)
                    .padding(20)
                    .frame(width: 250, height: 200)
                    .background(Color(hex: "008080"))
                    .foregroundColor(.white)
                    .shadow(color: Color(hex: "00ffff").opacity(0.5), radius: 20, x: 0, y: 10)
                    .cornerRadius(20)
            }
            Spacer()
        }
        .ignoresSafeArea()
    }
}

extension Text {
    enum CustomFont: String {
        case headline = "HelveticaNeue-Bold"
        // 定義其他自定義字型
    }
    
    func customFont(_ font: CustomFont, size: CGFloat) -> Text {
        self.font(.custom(font.rawValue, size: size))
    }
    
    func customFont(_ font: CustomFont) -> Text {
        customFont(font, size: 16)
    }
}
