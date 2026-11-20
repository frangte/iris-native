//
//  NewShopViewModel.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import Observation

/// Sheet for opening another shop while already signed in. The user becomes its owner.
@Observable
final class NewShopViewModel {
    var name = "" { didSet { errorMessage = nil } }
    var phone = "" { didSet { errorMessage = nil } }
    var address = "" { didSet { errorMessage = nil } }

    private(set) var isCreating = false
    private(set) var errorMessage: String?

    private let email: Email
    private let createShopUseCase: CreateShopUseCase
    private let onCreated: (Shop) -> Void
    private let onCancel: () -> Void

    init(
        email: Email,
        createShopUseCase: CreateShopUseCase,
        onCreated: @escaping (Shop) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.email = email
        self.createShopUseCase = createShopUseCase
        self.onCreated = onCreated
        self.onCancel = onCancel
    }

    var canCreate: Bool {
        ShopDraft(name: name, phone: phone, address: address) != nil
    }

    func create() async {
        guard !isCreating else { return }
        errorMessage = nil
        isCreating = true
        defer { isCreating = false }

        do {
            let shop = try await createShopUseCase.execute(name: name, phone: phone, address: address, owner: email)
            onCreated(shop)
        } catch let error as ShopError {
            errorMessage = error.message
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    func cancel() {
        onCancel()
    }
}
