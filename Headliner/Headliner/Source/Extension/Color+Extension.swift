//
//  Color+Extension.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI

public extension Color {

    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    static let subFontColor = Color(hex: "9A9FA5")
    static let subFontColorAlt = Color(hex: "888A90")
    static let accentMagenta = Color(hex: "FF29FF")
    static let sheetDivider = Color.white.opacity(0.1)
    static let inputDivider = Color.white.opacity(0.25)
    static let sheetGrabber = Color.white.opacity(0.4)
    static let playlistArtworkBackground = Color(hex: "787878").opacity(0.2)
    static let addPlaylistButtonBackground = Color(hex: "767680").opacity(0.12)
    static let sheetCloseButtonBackground = Color(hex: "787880").opacity(0.16)
}
