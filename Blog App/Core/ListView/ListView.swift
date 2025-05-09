//
//  ListView.swift
//  Blog App
//
//  Created by Ahmet Bostanci on 9.05.2025.
//

import SwiftUI
import WebKit
import JTSkeleton

struct ListView: View {
    @StateObject private var rssParser = RSSParser()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                if let error = rssParser.parseError {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                } else if rssParser.items.isEmpty {
                    ShimmerView()
                        .padding(.vertical, 12)
                } else {
                    ForEach(rssParser.items) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.title)
                                .font(.title2)
                            Text(item.description)
                                .font(.subheadline)
                                .lineLimit(2)
                            Text(item.pubDate)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        .onTapGesture {
                            rssParser.selectedBlog = item
                            rssParser.isSelected = true
                        }
                    }
                }
            }
            .listStyle(.inset)
            .navigationTitle("Swift Blog RSS")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                rssParser.parseFeed(url: "https://developer.apple.com/swift/blog/news.rss")
            }
            .onAppear {
                rssParser.parseFeed(url: "https://developer.apple.com/swift/blog/news.rss")
            }
            .navigationDestination(isPresented: $rssParser.isSelected){
                if let selectedBlog = rssParser.selectedBlog,
                   let url = URL(string: selectedBlog.link) {
                    WebView(url: url)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbarBackground(Color(.nav), for: .navigationBar)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.nav), for: .navigationBar)
        }
    }
}

#Preview {
    ListView()
    
}
