import Foundation
import Network

import libratone

struct Device : Identifiable {
  let id: NWEndpoint.Host

  init(id: ID) {
    self.id = id
  }

  init(id: ID, info: libratone.Device.Info) {
    self.init(id: id)
    self.info = info
  }

  var name: String {
    get {
      return info?.name ?? ""
    }
  }

  var info: libratone.Device.Info?
}

extension Device {
  static let sampleData: [Device] = [
    Device(id: NWEndpoint.Host.name("host1", nil), info: libratone.Device.Info(
      name: "Speaker 1 that has a very very long name",
      currentTrack: libratone.Device.CurrentTrackData(title: "Album name", subtitle: "Track name", playType: "spotify"),
      favorites: [
        libratone.Device.Favorite(ty: .VTuner, identity: "1", name: "Radio 1"),
        libratone.Device.Favorite(ty: .VTuner, identity: "2", name: "Radio 2"),
        libratone.Device.Favorite(ty: .VTuner, identity: "3", name: nil)
      ]
    )),
    Device(id: NWEndpoint.Host.name("host2", nil), info: libratone.Device.Info(name: "Speaker 2")),
    Device(id: NWEndpoint.Host.name("host3", nil), info: libratone.Device.Info(name: ""))
  ]
}

extension libratone.Device.Info {
  public init(
    name: String,
    currentTrack: libratone.Device.CurrentTrackData? = nil,
    favorites: [libratone.Device.Favorite] = []
  ) {
    self.init()
    self.name = name
    self.currentTrack = currentTrack
    self.favorites = favorites
  }
}

extension libratone.Device.CurrentTrackData {
  public init(title: String, subtitle: String, playType: String) {
    self.init()
    self.playTitle = title
    self.playSubtitle = subtitle
    self.playType = playType
  }
}

extension libratone.Device.Favorite {
  public init(ty: libratone.Device.Favorite.ChannelType, identity: String, name: String?) {
    self.init()
    self.channelType = ty
    self.channelIdentity = identity
    self.channelName = name
  }
}

extension libratone.Device.Favorite: Identifiable {
  public var id: String {
    return (channelType?.rawValue ?? "unknown channel type") + "\u{001c}" + (channelIdentity ?? "")
  }
}
