//
//  ShopInfoViewModel.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import Observation

/// Edit form for the shop name, phone and pickup address.
@Observable
final class ShopInfoViewModel {
    var name: String { didSet { errorMessage = nil } }
    var phone: String { didSet { errorMessage = nil } }
    var address: String { didSet { errorMessage = nil } }

    private(set) var isSaving = false
    private(set) var errorMessage: String?

    /// Last saved shop. The form compares against it to detect unsaved edits.
    private let shop: Shop
    private let updateShopUseCase: UpdateShopUseCase
    private let onSaved: (Shop) -> Void

    init(shop: Shop, updateShopUseCase: UpdateShopUseCase, onSaved: @escaping (Shop) -> Void) {
        self.shop = shop
        self.name = shop.name
        self.phone = shop.phone ?? ""
        self.address = shop.address ?? ""
        self.updateShopUseCase = updateShopUseCase
        self.onSaved = onSaved
    }

    // MARK: - Display data

    /// True when the trimmed form differs from the saved shop.
    var hasChanges: Bool {
        guard let draft = ShopDraft(name: name, phone: phone, address: address) else {
            // An emptied name is still an edit; saving it surfaces the validation message.
            return true
        }
        return draft.name != shop.name || draft.phone != shop.phone || draft.address != shop.address
    }

    // MARK: - Actions

    func save() async {
        guard !isSaving else { return }
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }

        do {
            let updated = try await updateShopUseCase.execute(shop: shop, name: name, phone: phone, address: address)
            onSaved(updated)
        } catch let error as ShopError {
            errorMessage = error.message
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }
}
