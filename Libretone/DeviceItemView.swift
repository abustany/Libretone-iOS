import SwiftUI

struct DeviceItemView: View {
    let device: Device
    var body: some View {
        HStack {
            Label("Speaker", systemImage: "speaker")
                .labelStyle(.iconOnly)
                .padding(.leading)
            Text(device.name).font(.title).padding()
            Spacer()
        }
    }
}

struct DeviceItemView_Previews: PreviewProvider {
    static var device = Device.sampleData[0]
    static var previews: some View {
        DeviceItemView(device: device)
            .previewLayout(.fixed(width: 400, height: 60))
    }
}
