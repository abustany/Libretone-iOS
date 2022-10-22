import SwiftUI
import Combine

import libratone

struct DeviceView: View {
  @Binding var device: Device
  @EnvironmentObject var deviceList: Devices
  @EnvironmentObject var preferenceStore: PreferenceStore

  // volume reflects the current slide value
  @State var volume: Float;

  // volumeSubject receives the new slider value after it changes
  private var volumeSubject = PassthroughSubject<Float, Never>()
  // debouncedVolume is a debounced version of volumeSubject
  private var debouncedVolume: AnyPublisher<Float, Never>;

  let onFavorite: (Bool) -> Void

  init(device: Binding<Device>, onFavorite: @escaping (Bool) -> Void) {
    self._device = device
    self.onFavorite = onFavorite

    self.debouncedVolume = volumeSubject.debounce(for: 0.5 /* sec */, scheduler: RunLoop.main).eraseToAnyPublisher()
    self._volume = State<Float>(initialValue: Float(device.info.wrappedValue?.volume ?? 0))
  }

  // some play types use weird conventions for title/subtitle... For example with Spotify the title is the album name and the subtitle the track name.
  var shouldRevertTitleAndSubtitle: Bool {
    get {
      device.info?.currentTrack?.playType == "spotify"
    }
  }

  var playTitle: String? {
    get {
      shouldRevertTitleAndSubtitle ? device.info?.currentTrack?.playSubtitle : device.info?.currentTrack?.playTitle
    }
  }

  var playSubtitle: String? {
    get {
      shouldRevertTitleAndSubtitle ? device.info?.currentTrack?.playTitle : device.info?.currentTrack?.playSubtitle
    }
  }

  var volumeSlideIcon: String {
    get {
      if volume == 0 {
        return "speaker"
      } else if volume <= 33 {
        return "speaker.wave.1"
      } else if volume <= 66 {
        return "speaker.wave.2"
      } else {
        return "speaker.wave.3"
      }
    }
  }

  var playPauseIcon: String {
    get {
      device.info?.playingState == .Play ? "pause.fill" : "play.fill"
    }
  }

  var isPreferredDevice: Bool {
    get {
      let prefs = preferenceStore.preferences
      return device.info?.name != nil && prefs.preferredDevice != nil && device.info?.name == prefs.preferredDevice
    }
  }

  var favoriteIcon: String {
    get {
      isPreferredDevice ? "heart.fill" : "heart"
    }
  }

  var body: some View {
    VStack {
      if (!(device.info?.favorites?.isEmpty ?? true)) {
        List {
          Section("device-view-section-favorites" as LocalizedStringKey) {
            ForEach(device.info?.favorites ?? []) { favorite in
              Button(action: {
                withDevice() { d in
                  d.setCurrentTrack(track: libratone.Device.CurrentTrackData(fromFavorite: favorite))
                }
              }) {
                if (favorite.channelName != nil) {
                  Text(favorite.channelName!)
                } else {
                  Text("device-view-favorite-unnamed")
               }
              }
            }
          }
        }.padding(.top)
      }

      Spacer()

      if let title = playTitle {
        Text(title)
          .font(.title)
          .padding(.bottom, 1)
      }

      if let subtitle = playSubtitle {
        Text(subtitle)
      }

      HStack {
        Button(action: { setPlayingState(.Previous) }) {
          Label("device-view-button-previous", systemImage: "backward.fill")
            .labelStyle(.iconOnly)
        }.padding(.horizontal)

        // define a frame for that button so that
        // switching between the play/pause icons
        // does not shift layout
        Button(action: { setPlayingState(.Toggle) }) {
          Label("device-view-button-playpause", systemImage: playPauseIcon)
            .labelStyle(.iconOnly)
        }.frame(width: 20, height: 20).padding(.horizontal)

        Button(action: { setPlayingState(.Next) }) {
          Label("device-view-button-forward", systemImage: "forward.fill")
            .labelStyle(.iconOnly)
        }.padding(.horizontal)
      }.padding(.top, 10)

      HStack {
        Label("device-view-volume-label", systemImage: volumeSlideIcon)
          .labelStyle(.iconOnly)
          .frame(width: 30, height: nil, alignment: .leading)
        Slider(value: $volume, in: 0...100, step: 1)
          .onChange(of: volume) { newVolume in volumeSubject.send(newVolume)}
          .onChange(of: device.info) { info in
            volume = Float(info?.volume ?? 0)
          }
          .onReceive(debouncedVolume) { volume in
            withDevice() { d in
              d.setVolume(volume: UInt8(volume))
            }
          }

      }.padding().padding(.bottom, 20)

    }
    .navigationTitle(device.name)
    .navigationBarItems(trailing: Button(action: {
      onFavorite(!isPreferredDevice)
    }) {
      Label("device-view-favorite-label", systemImage: favoriteIcon).labelStyle(.iconOnly)
    })
  }
}

extension DeviceView {
  func withDevice(action: (libratone.Device) -> Void) {
    deviceList.withDevice(id: device.id, action: action)
  }

  func setPlayingState(_ s: libratone.Device.PlayingStateChange) {
    withDevice() { d in
      d.setPlayingState(state: s)
    }
  }
}

struct DeviceView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      DeviceView(
        device: .constant(Device.sampleData[0]),
        onFavorite: {_ in }
      )
        .environmentObject(PreferenceStore())
        .environmentObject(Devices(devices: Device.sampleData))
    }
  }
}
