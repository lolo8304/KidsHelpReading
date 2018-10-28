//
//  RestApiManager.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 18.11.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import Foundation


public class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    static let GoogleAPIKey1 = "AIza"
    static let GoogleAPIKey2 = "SyDihpH"
    static let GoogleAPIKey3 = "TSOHidPN6bFfXK"
    static let GoogleAPIKey4 = "TR0G4CIHfMPrlE"
    static let GoogleAPIKey = "\(RestApiManager.GoogleAPIKey1)\(RestApiManager.GoogleAPIKey2)\(RestApiManager.GoogleAPIKey3)\(RestApiManager.GoogleAPIKey4)"
    static let GoogleEngineID1 = "011195144687224883122"
    static let GoogleEngineID2 = "o7p6a9fkkee"
    static let GoogleEngineID = "\(RestApiManager.GoogleEngineID1):\(RestApiManager.GoogleEngineID2)"
    static let GoogleFileTypes = "jpg%2C+png"
    static let GoogleResultFields = "items(cacheId%2CfileFormat%2Cimage(thumbnailHeight%2CthumbnailLink%2CthumbnailWidth)%2Ckind%2Clink%2Cmime%2Ctitle)"
    
    static let baseURL = "https://www.googleapis.com/customsearch/v1?&key=\(RestApiManager.GoogleAPIKey)&cx=\(RestApiManager.GoogleEngineID)&fileType=\(RestApiManager.GoogleFileTypes)&filter=1&searchType=image&fields=\(RestApiManager.GoogleResultFields)"
        
    // MARK: Perform a GET Request
    private func makeHTTPGetRequest(path: String, onCompletion: @escaping (_ json: JSON, _ error: Error?) -> Void) {
        guard let url = URL(string: path) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let jsonData = data {
                let json:JSON = JSON(data: jsonData)
                onCompletion(json, error)
            } else {
                onCompletion(JSON.null, error)
            }
        }.resume()
    }
    
    // MARK: Perform a POST Request
    private func makeHTTPPostRequest(path: String, body: [String: AnyObject], onCompletion: @escaping (JSON, Error?) -> Void) {
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL)
        
        // Set the method to POST
        request.httpMethod = "POST"
        
        do {
            // Set the POST body for the request
            let jsonBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = jsonBody
            let session = URLSession.shared
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                if let jsonData = data {
                    let json:JSON = JSON(data: jsonData)
                    onCompletion(json, nil)
                } else {
                    onCompletion(JSON.null, error)
                }
            })
            task.resume()
        } catch {
            // Create your personal error
            onCompletion(JSON.null, nil)
        }
    }
    
    func imageSearch(query: String, onCompletion: @escaping (JSON) -> Void) {
        let route = "\(RestApiManager.baseURL)&q=\(query)"
        makeHTTPGetRequest(path: route, onCompletion: { json, err in
            let jj = json as JSON
            if (jj["items"].type == .null) {
                onCompletion(JSON.null)
            } else {
                onCompletion(jj["items"])
            }
        })
    }
}


public class GoogleImageSearch {
    let query: String
    var results: JSON?
    
    public init(query: String) {
        self.query = query
    }
    
    func getImageData(onCompletion: @escaping (JSON) -> Void) {
        if (self.results == nil) {
            let urlQueryParameter: String = self.query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            RestApiManager.sharedInstance.imageSearch(query: urlQueryParameter, onCompletion: { (json: JSON) in
                self.results = json
                onCompletion(self.results!)
            })
        } else {
            onCompletion(self.results!)
        }
    }
    func getFirstImage(onCompletion: @escaping (String, String, Int, Int, String) -> Void) {
        self.getImageData( onCompletion: { (json: JSON) in
            if (self.results!.type == .array) {
                self.query.saveResult(json: self.results!)
                for entry in self.results!.array! {
                    self.query.saveEntry(json: entry)
                    onCompletion(
                        entry["link"].stringValue,
                        entry["image"]["thumbnailLink"].stringValue,
                        entry["image"]["thumbnailHeight"].intValue,
                        entry["image"]["thumbnailWidth"].intValue,
                        entry["mime"].stringValue)
                    return
                }
            }
        })
    }
    func getNextImage(onCompletion: @escaping (String, String, Int, Int, String) -> Void) {
        let jsonResult = self.query.loadResult()
        let jsonEntry = self.query.loadEntry()
        if (jsonResult != nil && jsonEntry != nil) {
            var found = false
            for entry in jsonResult!.array! {
                if (found) {
                    self.query.saveEntry(json: entry)
                    self.query.deleteImage()
                    onCompletion(
                        entry["link"].stringValue,
                        entry["image"]["thumbnailLink"].stringValue,
                        entry["image"]["thumbnailHeight"].intValue,
                        entry["image"]["thumbnailWidth"].intValue,
                        entry["mime"].stringValue)
                    return
                }
                if (entry["link"].stringValue == jsonEntry!["link"].stringValue) {
                    found = true
                }
            }
            var entry = jsonResult!.array![0]
            self.query.saveEntry(json: entry)
            onCompletion(
                entry["link"].stringValue,
                entry["image"]["thumbnailLink"].stringValue,
                entry["image"]["thumbnailHeight"].intValue,
                entry["image"]["thumbnailWidth"].intValue,
                entry["mime"].stringValue)
            
        } else {
            self.getFirstImage(onCompletion: onCompletion)
        }
    }

}

public extension String {
    func getDocumentsURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    func fileInDocumentsDirectory() -> String {
        let encodedFilename: String = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let fileURL = self.getDocumentsURL().appendingPathComponent(encodedFilename.lowercased())
        return fileURL.path
    }
    
    func saveImage(data: Data) {
        do {
            let fileName = self.fileInDocumentsDirectory()
            try data.write(to: URL(fileURLWithPath: fileName), options: .atomic)
        } catch {
            print(error)
        }
    }
    func deleteImage() {
        do {
            try FileManager.default.removeItem(atPath: self.fileInDocumentsDirectory())
        } catch {
            print(error)
        }
    }
    func saveResult(json: JSON) {
        do {
            let fileName = "\(self.fileInDocumentsDirectory()).json"
            try json.rawData().write(to: URL(fileURLWithPath: fileName), options: .atomic)
        } catch {
            print(error)
        }
    }
    func saveEntry(json: JSON) {
        do {
            let fileName = "\(self.fileInDocumentsDirectory()).entry.json"
            try json.rawData().write(to: URL(fileURLWithPath: fileName), options: .atomic)
        } catch {
            print(error)
        }
    }

    public func loadImage() -> UIImage? {
        do {
            let fileName = self.fileInDocumentsDirectory()
            let image = UIImage(contentsOfFile: fileName)
            if image == nil {
                print("image for '\(self)' not found. Get it")
                return nil
            } else {
                print("image for '\(self)' found in cache")
                return image;
            }
        }
    }
    func loadResult() -> JSON? {
        do {
            let fileName = "\(self.fileInDocumentsDirectory()).json"
            let data = try Data(contentsOf: URL(fileURLWithPath: fileName))
            print("JSON result for '\(self)' found in cache")
            return JSON(data: data);
        } catch {
            print("JSON result for '\(self)' not found. Get it")
            return nil
        }
    }
    func loadEntry() -> JSON? {
        do {
            let fileName = "\(self.fileInDocumentsDirectory()).entry.json"
            let data = try Data(contentsOf: URL(fileURLWithPath: fileName))
            print("JSON entry for '\(self)' found in cache")
            return JSON(data: data);
        } catch {
            print("JSON entry for '\(self)' not found. Get it")
            return nil
        }
    }

}


extension UIImageView {
    
    private func setImage(linkUrl: URL, name: String, onError: @escaping () -> Void) {
        URLSession.shared.dataTask(with: linkUrl) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data: Data = data, error == nil,
                let image = UIImage(data: data)
                else { onError(); return }
            DispatchQueue.main.async() { () -> Void in
                name.saveImage(data: data)
                self.image = image
                return
            }
        }.resume()
    }
    
    func downloadedFrom(linkUrl: URL, thumbnailUrl: URL, name: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        let localImage = name.loadImage()
        if (localImage == nil) {
            self.setImage(linkUrl: linkUrl, name: name, onError: {
                self.setImage(linkUrl: thumbnailUrl, name: name, onError: {
                })
            })
        } else {
            DispatchQueue.main.async() { () -> Void in
                self.image = localImage
            }
        }
    }
    func downloadedFrom(link: String, thumbnail: String, name: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let linkUrl = URL(string: link) else { return }
        guard let thumbnailUrl = URL(string: thumbnail) else { return }
        downloadedFrom(linkUrl: linkUrl, thumbnailUrl: thumbnailUrl, name: name, contentMode: mode)
    }
}
