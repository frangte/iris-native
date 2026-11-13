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

    func makeTodayViewModel(for shop: Shop) -> TodayViewModel {
        TodayViewModel(
            shop: shop,
            loadTodaySummary: LoadTodaySummaryUseCase(repository: orderRepository),
            // TODO: present the new-order form once it exists.
            onCreateOrder: {}
        )
    }
}
