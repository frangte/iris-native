//
//  ShopInfoViewModelTests.swift
//  irisTests
//
//  Created by SonnyHoang on 20/11/26.
//

import Testing
@testable import iris

@MainActor
struct ShopInfoViewModelTests {
    private final class Sink {
        var saved: Shop?
    }

    private struct UnexpectedError: Error {}

    private let shop = Shop(id: "1", name: "Tiệm hoa Mộc", phone: "0909", address: nil)
    private let repository = MockShopRepository()
    private let sink: Sink
    private let viewModel: ShopInfoViewModel

    init() {
        let sink = Sink()
        self.sink = sink
        viewModel = ShopInfoViewModel(
            shop: shop,
            updateShopUseCase: UpdateShopUseCase(repository: repository),
            onSaved: { sink.saved = $0 }
        )
    }

    @Test func startsWithShopDetailsAndNoChanges() {
        #expect(viewModel.name == "Tiệm hoa Mộc")
        #expect(viewModel.phone == "0909")
        #expect(viewModel.address == "")
        #expect(viewModel.hasChanges == false)
    }

    @Test func whitespaceOnlyEditsAreNotChanges() {
        viewModel.name = " Tiệm hoa Mộc "
        viewModel.address = "  "

        #expect(viewModel.hasChanges == false)
    }

    @Test func saveTrimsAndReportsShop() async {
        viewModel.name = " Hoa Xinh "
        viewModel.address = "12 Lê Lợi"

        await viewModel.save()

        #expect(repository.updatedShops.first?.id == "1")
        #expect(sink.saved?.name == "Hoa Xinh")
        #expect(sink.saved?.address == "12 Lê Lợi")
    }

    @Test func saveRequiresName() async {
        viewModel.name = "  "
        #expect(viewModel.hasChanges)

        await viewModel.save()

        #expect(viewModel.errorMessage == AppStrings.shopNameRequired)
        #expect(repository.updatedShops.isEmpty)
        #expect(sink.saved == nil)
    }

    @Test func saveFailureKeepsEdits() async {
        repository.updateError = UnexpectedError()
        viewModel.name = "Hoa Xinh"

        await viewModel.save()

        #expect(viewModel.errorMessage == AppStrings.somethingWentWrong)
        #expect(viewModel.name == "Hoa Xinh")
        #expect(sink.saved == nil)
    }
}
