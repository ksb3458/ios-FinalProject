//
//  LoadingView.swift
//  FinalProject
//
//  Created by 컴퓨터공학부 on 2023/06/15.
//

import UIKit

class LoadingView: UIView {

    static func showLoading() {
        DispatchQueue.main.async {
            // 최상단에 있는 window 객체 획득
            //guard let window = UIApplication.shared.windows.last else { return }
            var window : UIWindow = UIApplication.shared.windows.last!
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let keyWindow = windowScene.windows.first {
                   keyWindow.backgroundColor = .white
                window = keyWindow
            }
            //window.backgroundColor = .white
            let loadingIndicatorView: UIActivityIndicatorView
            if let existedView = (window as AnyObject).subviews.first(where: { $0 is UIActivityIndicatorView } ) as? UIActivityIndicatorView {
                loadingIndicatorView = existedView
            } else {
                loadingIndicatorView = UIActivityIndicatorView(style: .large)
                /// 다른 UI가 눌리지 않도록 indicatorView의 크기를 full로 할당
                loadingIndicatorView.frame = (window as AnyObject).frame
                loadingIndicatorView.color = .black
                (window as AnyObject).addSubview(loadingIndicatorView)
            }

            loadingIndicatorView.startAnimating()
        }
    }

    static func hideLoading() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }
            window.backgroundColor = .clear
            window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
        }
    }
}
