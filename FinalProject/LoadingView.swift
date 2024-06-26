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
            var window : UIWindow = UIApplication.shared.windows.last!
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let keyWindow = windowScene.windows.first {
                   keyWindow.backgroundColor = .black
                window = keyWindow
            }

            //let loadingIndicatorView: UIActivityIndicatorView
            //if let existedView = (window as AnyObject).subviews.first(where: { $0 is UIActivityIndicatorView } ) as? UIActivityIndicatorView {
            //    loadingIndicatorView = existedView
            //} else {
            //    loadingIndicatorView = UIActivityIndicatorView(style: .large)
            //    loadingIndicatorView.frame = (window as AnyObject).frame
            //    loadingIndicatorView.color = .white
            //    (window as AnyObject).addSubview(loadingIndicatorView)
            //}

            //loadingIndicatorView.startAnimating()
        }
    }

    static func hideLoading() {
        DispatchQueue.main.async {
            var window : UIWindow = UIApplication.shared.windows.last!
            window.backgroundColor = .clear
            window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
        }
    }
}
