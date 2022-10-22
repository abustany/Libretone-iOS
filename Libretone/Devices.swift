import Foundation

import libratone

class Devices : ObservableObject {
  @Published var list: [Device] = []
  @Published var error: String? = nil

  var rawByID: [Device.ID: libratone.Device] = [:]

  init() {
  }

  func start() {
    do {
      let deviceManager = DeviceManager()
      deviceManager.deviceDiscoveredHandler = { device in
        if self.rawByID[device.host] == nil {
          // only append the device to the list if we've never seen that host before.
          self.list.append(Device(id: device.host))
        }

        self.rawByID[device.host] = device

        device.infoChangedHandler = { info in
          guard let idx = self.list.firstIndex(where: {d in d.id == device.host}) else { return; }
          self.list[idx].info = info
        }
      }
      try deviceManager.start(queue: DispatchQueue.global())
    } catch {
      self.error = error.localizedDescription
    }
  }

  func withDevice(id: Device.ID, action: (libratone.Device) -> Void) {
    guard let device = rawByID[id] else { return; }
    action(device)
  }
}
