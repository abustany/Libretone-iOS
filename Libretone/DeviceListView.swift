import SwiftUI

struct DeviceListView: View {
  @State var namedDevices: [Device] = []
  @Binding var autoOpenDevice: String?
  @EnvironmentObject var deviceList: Devices
  @EnvironmentObject var preferenceStore: PreferenceStore

  let onFavorite: (String?) -> Void

  func deviceDestination(_ device: Binding<Device>) -> some View {
    DeviceView(
      device: device,
      onFavorite: { fav in
        onFavorite(fav ? device.wrappedValue.name : nil)
      }
    )
      .environmentObject(deviceList)
      .environmentObject(preferenceStore)
  }

  func shouldOpenDevice(_ device: Binding<Device>) -> Binding<Bool> {
    Binding<Bool>(
      get: {
        device.wrappedValue.name == autoOpenDevice
      },
      set: { val in
        autoOpenDevice = val ? device.wrappedValue.name : nil
      }
    )
  }

  var body: some View {
    VStack {
      List {
        ForEach($namedDevices) { $device in
          NavigationLink(
            destination: deviceDestination($device),
            isActive: shouldOpenDevice($device)
          ) {
            DeviceItemView(device: device)
          }
        }
      }
      .overlay {
        if (namedDevices.isEmpty) {
          ProgressView("device-list-looking")
        }
      }
      .onReceive(deviceList.$list) { devices in
        self.namedDevices = devices.filter({!$0.name.isEmpty})
      }
    }.navigationTitle("device-list-title")
  }
}

struct DeviceListView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      NavigationView {
        DeviceListView(
          autoOpenDevice: .constant(nil),
          onFavorite: {_ in}
        )
      }
      .environmentObject(PreferenceStore())
      .environmentObject(Devices(devices: Device.sampleData))

      NavigationView {
        DeviceListView(
          autoOpenDevice: .constant(nil),
          onFavorite: {_ in}
        )
      }
      .environmentObject(PreferenceStore())
      .environmentObject(Devices(devices: []))
    }.environment(\.locale, .init(identifier: "fr-FR"))
  }
}

extension Devices {
  convenience init(devices: [Device]) {
    self.init()
    self.list = devices
  }
}
