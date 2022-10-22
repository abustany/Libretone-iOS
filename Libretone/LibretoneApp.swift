import SwiftUI

@main
struct LibretoneApp: App {
  @StateObject var deviceList = Devices()
  @StateObject private var prefsStore = PreferenceStore()
  @State var autoOpen: String? = nil

  var body: some Scene {
    WindowGroup {
      NavigationView {
        DeviceListView(
          autoOpenDevice: $autoOpen,
          onFavorite: { name in
            let updatedPrefs = prefsStore.preferences.withFavoriteDevice(name: name)
            PreferenceStore.save(prefs: updatedPrefs) { result in
              switch result {
              case .failure(let error):
                fatalError(error.localizedDescription)
              case .success():
                prefsStore.preferences = updatedPrefs
              }
            }
          }
        )
          .environmentObject(deviceList)
          .environmentObject(prefsStore)
      }
      .navigationViewStyle(.stack)
      .onAppear {
        deviceList.start()
        PreferenceStore.load { result in
          switch result {
          case .failure(let error):
            fatalError(error.localizedDescription)
          case .success(let prefs):
            prefsStore.preferences = prefs
            autoOpen = prefs.preferredDevice
          }
        }
      }
    }
  }
}
