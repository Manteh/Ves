//
//  Funcs.swift
//  Ves
//
//  Created by Mantas Simanauskas on 2021-09-18.
//

import Foundation
import SwiftUI
import AVKit

let orangeGradientTopBottom = LinearGradient(gradient: Gradient(colors: [Color.init(hex: "ED7E3F"), Color.init(hex: "EB713F")]), startPoint: .top, endPoint: .bottom)

let orangeGradientLeftRight = LinearGradient(gradient: Gradient(colors: [Color.init(hex: "F19B3E"), Color.init(hex: "E65340")]), startPoint: .leading, endPoint: .trailing)

let orangeGradientBG = LinearGradient(gradient: Gradient(colors: [Color.init(hex: "F19B3E"), Color.init(hex: "E65340")]), startPoint: .top, endPoint: .bottom)

let orangeGradientText = LinearGradient(gradient: Gradient(colors: [Color.init(hex: "ED7F3F"), Color.init(hex: "EB733F")]), startPoint: .top, endPoint: .bottom)

let blueGradientButton = LinearGradient(gradient: Gradient(colors: [Color.init(hex: "47ABEF"), Color.init(hex: "6062E9")]), startPoint: .leading, endPoint: .trailing)

let blueGradientBG = LinearGradient(gradient: Gradient(colors: [Color.init(hex: "47ABEF"), Color.init(hex: "6062E9")]), startPoint: .top, endPoint: .bottom)

let blueGradientText = LinearGradient(gradient: Gradient(colors: [Color.init(hex: "4AA1EE"), Color.init(hex: "508FED")]), startPoint: .top, endPoint: .bottom)

extension View {
    func selfSizeMask<T: View>(_ mask: T) -> some View {
        ZStack {
            self.opacity(0)
            mask.mask(self)
        }.fixedSize()
    }
}

extension View {
    func selfSizeMaskOrColor<T: View>(_ mask: T, _ enableMask: Bool) -> some View {
        ZStack {
            if enableMask {
                self.opacity(0)
                mask.mask(self)
            } else {
                self.opacity(1)
                self.foregroundColor(.white)
            }
        }.fixedSize()
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

struct CustomTextField: UIViewRepresentable {

   class Coordinator: NSObject, UITextFieldDelegate {

      @Binding var text: String
      @Binding var nextResponder : Bool?
      @Binding var isResponder : Bool?
      @Binding var textLimit: Int

      init(text: Binding<String>,nextResponder : Binding<Bool?> , isResponder : Binding<Bool?>, textLimit: Binding<Int>) {
        _text = text
        _isResponder = isResponder
        _nextResponder = nextResponder
        _textLimit = textLimit
      }

      func textFieldDidChangeSelection(_ textField: UITextField) {
        text = textField.text ?? ""
      }
    
      func textFieldDidBeginEditing(_ textField: UITextField) {
         DispatchQueue.main.async {
            self.isResponder = true
         }
      }
    
      func textFieldDidEndEditing(_ textField: UITextField) {
         DispatchQueue.main.async {
             self.isResponder = false
             if self.nextResponder != nil {
                 self.nextResponder = true
             }
         }
      }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") || (text.count >= textLimit && string != ""){
            return false
        }
        return true
    }
  }

  @Binding var text: String
  @Binding var nextResponder : Bool?
  @Binding var isResponder : Bool?
  @Binding var textLimit: Int

  var isSecured : Bool = false
  var keyboard : UIKeyboardType

  func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
      let textField = UITextField(frame: .zero)
      textField.isSecureTextEntry = isSecured
      textField.autocapitalizationType = .sentences
      textField.autocorrectionType = .no
      textField.keyboardType = .asciiCapable
      textField.delegate = context.coordinator
      return textField
  }

  func makeCoordinator() -> CustomTextField.Coordinator {
    return Coordinator(text: $text, nextResponder: $nextResponder, isResponder: $isResponder, textLimit: $textLimit)
  }

  func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
       uiView.text = text
       if isResponder ?? false {
            uiView.becomeFirstResponder()
       }
  }

}

class PlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        guard let path = Bundle.main.path(forResource: "video", ofType:"mp4") else {
            debugPrint("video.mp4 not found")
            return
        }
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.play()
        
        
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(willEnterForeground(_:)),
          name: UIApplication.willEnterForegroundNotification,
          object: nil
        )
    

        layer.addSublayer(playerLayer)
    }
    
    @objc
    private func willEnterForeground(_ notification: Notification) {
        self.playerLayer.player?.play()
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: .zero, completionHandler: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}



