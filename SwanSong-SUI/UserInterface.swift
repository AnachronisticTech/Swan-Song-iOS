//
//  UserInterface.swift
//  SwanSong
//
//  Created by Daniel Marriner on 14/10/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import SwiftUI
import UIKit
import MediaPlayer
import VisualEffects
import SFSafeSymbols
import ASCollectionView

class Preferences: ObservableObject {
    @Environment(\.colorScheme) var colorScheme

    enum TintColor: String, CaseIterable {
        case Red, Orange, Yellow, Green, Teal, Blue, Purple, Pink

        var color: UIColor {
            switch self {
            case .Red: return .systemRed
            case .Orange: return .systemOrange
            case .Yellow: return .systemYellow
            case .Green: return .systemGreen
            case .Teal: return .systemTeal
            case .Blue: return .systemBlue
            case .Purple: return .systemPurple
            case .Pink: return .systemPink
            }
        }
    }

    var lightTint: TintColor = .Blue
    var darkTint: TintColor = .Red

    @Published var tint: TintColor = .Blue

    init() {
        // get tint preferences from user defaults
//        tint = colorScheme == .dark ? darkTint : lightTint
    }


}

struct AudioSlider: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var preferences: Preferences
    @Binding var value: Double

    private class AudioTrack: UISlider {
        override func trackRect(forBounds bounds: CGRect) -> CGRect {
            let height: CGFloat = 10
            let origin = CGPoint(x: bounds.minX, y: bounds.midY - (height / 2))
            return CGRect(origin: origin, size: CGSize(width: bounds.width, height: height))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    func makeUIView(context: Context) -> UISlider {
        let control = AudioTrack()
        control.isContinuous = false
        control.setThumbImage(
            UIImage(
                color: colorScheme == .dark ? preferences.darkTint.color : preferences.lightTint.color,
                size: CGSize(width: 1, height: 6)
            ),
            for: .normal
        )
        control.setMinimumTrackImage(
            UIImage(
                color: colorScheme == .dark ? preferences.darkTint.color : preferences.lightTint.color,
                size: CGSize(width: 5, height: 3)
            ),
            for: .normal
        )
        control.setMaximumTrackImage(
            UIImage(
                color: colorScheme == .dark ? .systemGray : .systemGray5,
                size: CGSize(width: 5, height: 3)
            ),
            for: .normal
        )

        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged),
            for: .valueChanged
        )
        return control
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.value = Float(self.value)
    }

    class Coordinator: NSObject {
        var value: Binding<Double>

        init(value: Binding<Double>) {
            self.value = value
        }

        @objc func valueChanged(_ sender: UISlider) {
            self.value.wrappedValue = Double(sender.value)
        }
    }
}

struct VolumeView: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        MPVolumeView(frame: .zero)
    }

    func updateUIView(_ view: MPVolumeView, context: Context) {}
}

struct ArtDetailListCell: View {
    @Environment(\.colorScheme) var colorScheme

    @State var title: String = ""
    @State var detail: String = ""
    @State var image: UIImage? = nil

    @State var size: Size = .large
    @State var isFolder: Bool = false

    var body: some View {
        HStack {
            ZStack {
                Image(artwork: image)
                    .resizable()
                    .frame(width: size.art, height: size.art)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: size.rounding))
                if isFolder {
                    Group {
                        VisualEffectBlur(
                            blurStyle: colorScheme == .dark ? .prominent : .systemThinMaterialDark,
                            vibrancyStyle: .fill
                        ) {
                            Rectangle()
                        }
                        .opacity(0.8)
                        .clipShape(RoundedRectangle(cornerRadius: size.rounding))
                        Image(systemSymbol: .folder)
                            .font(.system(size: size.art * 0.6))
                            .foregroundColor(.white)
                            .clipped()
                    }
                    .frame(width: size.art, height: size.art)
                }
            }
            .padding(.vertical, 5.0)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 17))
                Text(detail)
                    .padding(.top, 1.0)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.vertical, 5.0)
        }
        .padding(.vertical, size.titleTopPadding)
        .listRowInsets(EdgeInsets(
            top: 0,
            leading: 15,
            bottom: 0,
            trailing: 15
        ))
    }

    enum Size {
        case large
        case medium
        case small

        var art: CGFloat {
            switch self {
                case .large: return 100
                case .medium: return 75
                case.small: return 50
            }
        }

        var rounding: CGFloat {
            switch self {
                case .large: return 10
                case .medium, .small: return 5
            }
        }

        var titleTopPadding: CGFloat {
            switch self {
                case .large: return 5
                case .medium, .small: return 0
            }
        }
    }
}

struct NumberDetailListCell: View {
    @State var title: String = ""
    @State var detail: String = ""
    @State var number: Int = 0

    var body: some View {
        HStack {
            Group {
                Text("\(number)")
                    .frame(minWidth: 25)
                    .foregroundColor(.gray)
                    .font(.system(size: 17))
            }
            .padding(.horizontal, 10)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 17))
                Text(detail)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 10)
        .listRowInsets(EdgeInsets(
            top: 0,
            leading: 15,
            bottom: 0,
            trailing: 15
        ))
    }
}

struct FooterListCell: View {
    @State var detail: String = ""

    var body: some View {
        HStack {
            Spacer()
            Text(detail)
                .font(.system(size: 13))
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.vertical, 20.0)
        .listRowInsets(EdgeInsets(
            top: 0,
            leading: 15,
            bottom: 0,
            trailing: 15
        ))
    }
}

struct UserInterface: View {
    var body: some View {
        List {
            ArtDetailListCell(
                size: .large,
                isFolder: true
            )
            ArtDetailListCell(size: .large)
            ArtDetailListCell(size: .medium)
            ArtDetailListCell(size: .small)
            NumberDetailListCell()
            FooterListCell()
        }
    }
}

struct UserInterface_Previews: PreviewProvider {
    static var previews: some View {
        UserInterface()
    }
}

struct VibranceTestView: View {
    @State var effects: [Int] = {
        var indices = Array(0...20)
        indices.removeAll { $0 == 3 }
        return indices
    }()

    var body: some View {
        List {
            ForEach(effects, id: \.self) { i in
                let effect = UIBlurEffect.Style.init(rawValue: i)!
                VStack {
                    Text("Effect \(i)")
                    ZStack {
                        Image(uiImage: UIImage(named: "cover.jpg")!)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .clipped()
                            .edgesIgnoringSafeArea(.all)
                        VisualEffectBlur(
                            blurStyle: effect,
                            vibrancyStyle: .fill
                        ) {
                            Rectangle()
                                .edgesIgnoringSafeArea(.all)
                        }
                        .edgesIgnoringSafeArea(.all)
                    }
                    .padding()
                }
            }
        }
    }
}
