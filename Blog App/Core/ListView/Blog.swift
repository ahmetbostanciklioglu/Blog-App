//
//  List.swift
//  Blog App
//
//  Created by Ahmet Bostanci on 9.05.2025.
//

import SwiftUI

struct Blog: Identifiable {
    let id = UUID()
    let title: String
    let link: String
    let description: String
    let pubDate: String
}
