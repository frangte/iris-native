//
//  DSSegmentedPicker.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Thin wrapper over the system segmented `Picker`, which renders with Liquid Glass on iOS 26+
/// (translucent sliding thumb, native selection animation). Segments share the width equally.
struct DSSegmentedPicker<Value: Hashable>: View {
    let options: [Value]
    @Binding var selection: Value
    let title: (Value) -> String

    var body: some View {
        Picker(selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(title(option)).tag(option)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }
}

#Preview {
    @Previewable @State var method: DeliveryMethod = .delivery
    DSSegmentedPicker(options: DeliveryMethod.allCases, selection: $method) { $0.title }
        .padding(DSSpacing.screenPadding)
        .background(Color.groupedBackground)
}
