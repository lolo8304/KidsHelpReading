//
//  RestApiManager.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 18.11.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import Foundation


class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    let baseURL = "https://www.googleapis.com/customsearch/v1?&key=AIzaSyDihpHTSOHidPN6bFfXKTR0G4CIHfMPrlE&cx=011195144687224883122:o7p6a9fkkee&fileType=jpg%2C+png&filter=1&searchType=image&fields=items(cacheId%2CfileFormat%2Cimage(thumbnailHeight%2CthumbnailLink%2CthumbnailWidth)%2Ckind%2Clink%2Cmime%2Ctitle)&q="
        
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
        let route = "\(baseURL)\(query)"
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


class GoogleImageSearch {
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
    func getFirstImage(onCompletion: @escaping (String, Int, Int, String) -> Void) {
        self.getImageData( onCompletion: { (json: JSON) in
            if (self.results!.type == .array) {
                for entry in self.results!.array! {
                    onCompletion(
                        entry["image"]["thumbnailLink"].stringValue,
                        entry["image"]["thumbnailHeight"].intValue,
                        entry["image"]["thumbnailWidth"].intValue,
                        entry["mime"].stringValue)
                }
            }
        })
    }
}

extension String {
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

    func loadImage() -> UIImage? {
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

}


extension UIImageView {
    
    func downloadedFrom(url: URL, name: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        let localImage = name.loadImage()
        if (localImage == nil) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data: Data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async() { () -> Void in
                    name.saveImage(data: data)
                    self.image = image
                }
            }.resume()
        } else {
            DispatchQueue.main.async() { () -> Void in
                self.image = localImage
            }
        }
    }
    func downloadedFrom(link: String, name: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, name: name, contentMode: mode)
    }
}
