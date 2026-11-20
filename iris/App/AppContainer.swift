//
//  AppContainer.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Composition root: the single place that decides which Data implementations back the Domain.
/// Views and view models never construct dependencies themselves; they receive them from here.
final class AppContainer {
    let sessionStore = AppSessionStore()
    let authRepository: AuthRepository
    let shopRepository: ShopRepository
    let orderRepository: OrderRepository
    /// Login code hint shown in development builds. `nil` in production.
    let debugCodeHint: String?

    init(
        authRepository: AuthRepository,
        shopRepository: ShopRepository,
        orderRepository: OrderRepository,
        debugCodeHint: String? = nil
    ) {
        self.authRepository = authRepository
        self.shopRepository = shopRepository
        self.orderRepository = orderRepository
        self.debugCodeHint = debugCodeHint
    }

    /// Configuration used when running the app. Swap in API-backed repositories here.
    static func live() -> AppContainer {
        #if DEBUG
        AppContainer(
            authRepository: InMemoryAuthRepository(),
            shopRepository: InMemoryShopRepository(),
            orderRepository: InMemoryOrderRepository(),
            debugCodeHint: InMemoryAuthRepository.fixedCode
        )
        #else
        AppContainer(
            authRepository: InMemoryAuthRepository(),
            shopRepository: InMemoryShopRepository(),
            orderRepository: InMemoryOrderRepository()
        )
        #endif
    }

    // MARK: - Factories

    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(
            requestLoginCode: RequestLoginCodeUseCase(repository: authRepository),
            verifyLoginCode: VerifyLoginCodeUseCase(repository: authRepository),
            debugCodeHint: debugCodeHint,
            onAuthenticated: { [sessionStore] session in sessionStore.signIn(session) }
        )
    }

    func makeOnboardingViewModel(for session: AuthSession) -> OnboardingViewModel {
        OnboardingViewModel(
            email: session.email,
            createShopUseCase: CreateShopUseCase(repository: shopRepository),
            joinShopUseCase: JoinShopUseCase(repository: shopRepository),
            onShopReady: { [sessionStore] shop in sessionStore.enter(shop) },
            onLogout: { [sessionStore] in sessionStore.signOut() }
        )
    }

    func makeShopViewModel(for shop: Shop, email: Email) -> ShopViewModel {
        ShopViewModel(
            shop: shop,
            email: email,
            displayName: sessionStore.displayName,
            loadMembersUseCase: LoadShopMembersUseCase(repository: shopRepository),
            updateShopUseCase: UpdateShopUseCase(repository: shopRepository),
            createInviteCodeUseCase: CreateInviteCodeUseCase(repository: shopRepository),
            createShopUseCase: CreateShopUseCase(repository: shopRepository),
            joinShopUseCase: JoinShopUseCase(repository: shopRepository),
            onShopChanged: { [sessionStore] shop in sessionStore.enter(shop) },
            onDisplayNameChanged: { [sessionStore] name in sessionStore.updateDisplayName(name) },
            onLogout: { [sessionStore] in sessionStore.signOut() }
        )
    }

    /// `actor` is the signed-in member; every order they create or change is attributed to them.
    func makeTodayViewModel(for shop: Shop, actor: Email) -> TodayViewModel {
        TodayViewModel(
            shop: shop,
            actor: actor,
            loadTodaySummary: LoadTodaySummaryUseCase(repository: orderRepository),
            createOrderUseCase: CreateOrderUseCase(repository: orderRepository),
            makeOrderDetail: { [unowned self] order, onChanged, onDeleted in
                self.makeOrderDetailViewModel(order: order, shop: shop, actor: actor, onChanged: onChanged, onDeleted: onDeleted)
            }
        )
    }

    func makeOrderDetailViewModel(
        order: Order,
        shop: Shop,
        actor: Email,
        onChanged: @escaping () -> Void,
        onDeleted: @escaping () -> Void
    ) -> OrderDetailViewModel {
        OrderDetailViewModel(
            order: order,
            shop: shop,
            actor: actor,
            loadOrder: LoadOrderUseCase(repository: orderRepository),
            changeStatusUseCase: ChangeOrderStatusUseCase(repository: orderRepository),
            deleteOrderUseCase: DeleteOrderUseCase(repository: orderRepository),
            onChanged: onChanged,
            onDeleted: onDeleted
        )
    }
}
