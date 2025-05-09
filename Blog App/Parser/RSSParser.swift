//
//  BlogService.swift
//  Blog App
//
//  Created by Ahmet Bostanci on 9.05.2025.
//

import Foundation


class RSSParser: NSObject, XMLParserDelegate, ObservableObject {
    @Published var items: [Blog] = []
    @Published var currentElement = ""
    @Published var currentTitle = ""
    @Published var currentLink = ""
    @Published var currentDescription = ""
    @Published var currentPubDate = ""
    @Published var parseError: Error?
    @Published var selectedBlog: Blog?
    @Published var isSelected: Bool = false
    
    private var parser: XMLParser!
    private var completion: (([Blog]) -> Void)?
    
    func parseFeed(url: String, completion: (([Blog]) -> Void)? = nil) {
        self.completion = completion
        
        guard let url = URL(string: url) else {
            parseError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.parseError = error
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.parseError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                }
                return
            }
            
            self.parser = XMLParser(data: data)
            self.parser.delegate = self
            self.parser.parse()
        }
        
        task.resume()
    }
    
    
    // XMLParserDelegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
       
        DispatchQueue.main.async {
            self.currentElement = elementName
        }
        
        if currentElement == "item" {
            DispatchQueue.main.async {
                self.currentTitle = ""
                self.currentLink = ""
                self.currentDescription = ""
                self.currentPubDate = ""
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            switch currentElement {
            case "title": self.currentTitle += string
            case "link": self.currentLink += string
            case "description": self.currentDescription += string
            case "pubDate": self.currentPubDate += string
            default: break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let item = Blog(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                description: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                pubDate: currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            DispatchQueue.main.async {
                self.items.append(item)
            }
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        DispatchQueue.main.async {
            self.parseError = parseError
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.async {
            self.completion?(self.items)
        }
    }
}
