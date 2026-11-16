//
//  DeliveryScheduleCard.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Delivery day and time: today/tomorrow chips with a date picker, preset time slots,
/// and start/end pickers that are dimmed while "no fixed time" is selected.
struct DeliveryScheduleCard: View {
    @Bindable var viewModel: NewOrderViewModel

    var body: some View {
        DSFormCard {
            dateRow
            timeSlotRow
            timeRow(label: AppStrings.fromTime, selection: $viewModel.startTimeDate)
            timeRow(label: AppStrings.toTime, selection: $viewModel.endTimeDate)
        }
    }

    // MARK: - Rows

    private var dateRow: some View {
        HStack(alignment: .center, spacing: DSSpacing.md) {
            Text(AppStrings.date)
                .font(DSFont.body)
                .foregroundStyle(Color.label)

            // Flow layout so the chips and picker wrap on narrow screens instead of clipping.
            DSFlowLayout(spacing: DSSpacing.sm, lineSpacing: DSSpacing.sm) {
                DSChip(title: AppStrings.today, isSelected: viewModel.isTodaySelected, isCompact: true, action: viewModel.selectToday)
                DSChip(title: AppStrings.tomorrow, isSelected: viewModel.isTomorrowSelected, isCompact: true, action: viewModel.selectTomorrow)
                DatePicker(AppStrings.date, selection: $viewModel.input.deliveryDate, displayedComponents: .date)
                    .labelsHidden()
            }
        }
        .padding(.horizontal, DSSpacing.controlInset)
        .padding(.vertical, DSSpacing.sm)
        .frame(minHeight: DSSpacing.rowHeight)
    }

    private var timeSlotRow: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text(AppStrings.timeSlot)
                .font(DSFont.body)
                .foregroundStyle(Color.label)

            DSFlowLayout {
                ForEach(viewModel.timeSlotOptions) { option in
                    DSChip(title: option.title, isSelected: option.isSelected) {
                        viewModel.select(option)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DSSpacing.controlInset)
        .padding(.vertical, DSSpacing.md)
    }

    private func timeRow(label: String, selection: Binding<Date>) -> some View {
        DSRow(label: label) {
            DatePicker(label, selection: selection, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .disabled(!viewModel.input.hasTimeWindow)
        .opacity(viewModel.input.hasTimeWindow ? 1 : 0.45)
    }
}

#Preview {
    DeliveryScheduleCard(
        viewModel: NewOrderViewModel(
            shop: Shop(id: "1", name: "ABC", phone: nil, address: nil),
            createOrderUseCase: CreateOrderUseCase(repository: InMemoryOrderRepository(simulatedDelay: .zero)),
            onSaved: { _ in },
            onCancel: {}
        )
    )
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
