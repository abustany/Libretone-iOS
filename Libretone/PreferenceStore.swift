import Foundation
import SwiftUI

struct Preferences: Codable {
  var preferredDevice: String?
}

extension Preferences {
  func withFavoriteDevice(name: String?) -> Preferences {
    var current = self
    current.preferredDevice = name
    return current
  }
}

class PreferenceStore: ObservableObject {
  @Published var preferences = Preferences(preferredDevice: nil)

  private static func fileURL() throws -> URL {
    try FileManager.default.url(
      for: .documentDirectory,
         in: .userDomainMask,
         appropriateFor: nil,
         create: false
    ).appendingPathComponent("prefs.data")
  }

  static func load(completion: @escaping (Result<Preferences, Error>) -> Void) {
    DispatchQueue.global(qos: .background).async {
      do {
        let fileURL = try fileURL()
        guard let file = try? FileHandle(forReadingFrom: fileURL) else {
          DispatchQueue.main.async {
            completion(.success(Preferences()))
          }
          return
        }
        let res = try JSONDecoder().decode(Preferences.self, from: file.availableData)
        DispatchQueue.main.async {
          completion(.success(res))
        }
      } catch {
        DispatchQueue.main.async {
          completion(.failure(error))
        }
      }
    }
  }

  static func save(prefs: Preferences, completion: @escaping (Result<Void, Error>) -> Void) {
    do {
      let data = try JSONEncoder().encode(prefs)
      let outfile = try fileURL()
      try data.write(to: outfile)
      DispatchQueue.main.async {
        completion(.success(()))
      }
    } catch {
      DispatchQueue.main.async {
        completion(.failure(error))
      }
    }
  }
}
