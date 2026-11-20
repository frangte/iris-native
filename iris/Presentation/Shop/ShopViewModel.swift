//
//  ShopViewModel.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import Observation

/// Screens pushed from the Shop tab.
enum ShopRoute: Hashable {
    case info
    case payment
    case members
}

/// Shop tab root: shop header, links to shop settings and members, joining or opening
/// another shop, the account name, and sign-out. Builds the view models of the pushed screens.
@Observable
final class ShopViewModel {
    /// Builds the members screen for a shop, starting from the members already loaded.
    typealias MembersFactory = (_ shop: Shop, _ members: [ShopMember]) -> ShopMembersViewModel

    /// Email of the signed-in user.
    let email: Email

    private(set) var shop: Shop
    private(set) var members: [ShopMember] = []
    private(set) var isJoining = false
    private(set) var errorMessage: String?

    /// Name shown next to this user's changes in order history.
    var displayName: String {
        didSet { onDisplayNameChanged(displayName) }
    }

    /// Invite code input. Only letters and digits are kept, uppercased and capped at `InviteCode.length`.
    var inviteCode: String {
        get { rawInviteCode }
        set { updateInviteCode(newValue) }
    }
    private var rawInviteCode = ""

    /// Pushed screens. Settable so the navigation stack can bind to it.
    var path: [ShopRoute] = []
    /// True while the new-shop sheet is shown.
    var isCreatingShop = false
    /// True while the sign-out confirmation is shown.
    var isConfirmingLogout = false

    private let loadMembersUseCase: LoadShopMembersUseCase
    private let updateShopUseCase: UpdateShopUseCase
    private let makeMembers: MembersFactory
    private let createShopUseCase: CreateShopUseCase
    private let joinShopUseCase: JoinShopUseCase
    /// Called with the shop the user now works in: the edited current shop, or a newly created or joined one.
    private let onShopChanged: (Shop) -> Void
    private let onDisplayNameChanged: (String) -> Void
    private let onLogout: () -> Void

    init(
        shop: Shop,
        email: Email,
        displayName: String,
        loadMembersUseCase: LoadShopMembersUseCase,
        updateShopUseCase: UpdateShopUseCase,
        createShopUseCase: CreateShopUseCase,
        joinShopUseCase: JoinShopUseCase,
        onShopChanged: @escaping (Shop) -> Void,
        onDisplayNameChanged: @escaping (String) -> Void,
        onLogout: @escaping () -> Void,
        makeMembers: @escaping MembersFactory
    ) {
        self.shop = shop
        self.email = email
        self.displayName = displayName
        self.loadMembersUseCase = loadMembersUseCase
        self.updateShopUseCase = updateShopUseCase
        self.createShopUseCase = createShopUseCase
        self.joinShopUseCase = joinShopUseCase
        self.onShopChanged = onShopChanged
        self.onDisplayNameChanged = onDisplayNameChanged
        self.onLogout = onLogout
        self.makeMembers = makeMembers
    }

    // MARK: - Display data

    /// Role of the signed-in user in this shop, e.g. "Chủ shop". `nil` until members load.
    var roleTitle: String? {
        members.first { $0.email == email }?.role.title
    }

    /// "1 người". `nil` until members load.
    var memberCountText: String? {
        members.isEmpty ? nil : "\(members.count) \(AppStrings.peopleCountSuffix)"
    }

    var canJoinShop: Bool {
        InviteCode(rawInviteCode) != nil
    }

    /// "Floied · bản thử nghiệm"
    var buildLine: String {
        "\(AppStrings.appName) · \(AppStrings.betaBuild)"
    }

    // MARK: - Actions

    func load() async {
        do {
            members = try await loadMembersUseCase.execute(for: shop)
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    func joinShop() async {
        guard !isJoining else { return }
        errorMessage = nil
        isJoining = true
        defer { isJoining = false }

        do {
            let joined = try await joinShopUseCase.execute(rawInviteCode: rawInviteCode, member: email)
            rawInviteCode = ""
            onShopChanged(joined)
        } catch let error as ShopError {
            errorMessage = error.message
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    func openNewShop() {
        isCreatingShop = true
    }

    func requestLogout() {
        isConfirmingLogout = true
    }

    func logout() {
        onLogout()
    }

    // MARK: - Child screens

    /// Saving updates the header, tells the app about the new details and pops back here.
    func makeShopInfoViewModel() -> ShopInfoViewModel {
        ShopInfoViewModel(
            shop: shop,
            updateShopUseCase: updateShopUseCase,
            onSaved: { [weak self] shop in
                guard let self else { return }
                self.shop = shop
                self.onShopChanged(shop)
                self.path.removeAll()
            }
        )
    }

    /// Starts from the members already loaded here so the list shows without a spinner.
    func makeMembersViewModel() -> ShopMembersViewModel {
        makeMembers(shop, members)
    }

    /// Creating closes the sheet and switches the app to the new shop.
    func makeNewShopViewModel() -> NewShopViewModel {
        NewShopViewModel(
            email: email,
            createShopUseCase: createShopUseCase,
            onCreated: { [weak self] shop in
                self?.isCreatingShop = false
                self?.onShopChanged(shop)
            },
            onCancel: { [weak self] in
                self?.isCreatingShop = false
            }
        )
    }

    // MARK: - Private

    private func updateInviteCode(_ newValue: String) {
        errorMessage = nil
        let normalized = newValue
            .filter { $0.isLetter || $0.isNumber }
            .uppercased()
            .prefix(InviteCode.length)
        rawInviteCode = String(normalized)
    }
}
