# Graph Report - iris  (2026-11-16)

## Corpus Check
- Corpus is ~15,811 words - fits in a single context window. You may not need a graph.

## Summary
- 644 nodes · 1222 edges · 28 communities (23 shown, 5 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 197 edges (avg confidence: 0.85)
- Token cost: 29,715 input · 0 output

## Community Hubs (Navigation)
- Order Domain Models
- Auth Login Flow
- New Order ViewModel
- Today Tab & Order Use Cases
- Onboarding Screen
- Shop Repository & Invite Code
- App Composition Root
- In-Memory Repositories
- Domain Error Types
- Auth View & Text Components
- Form Row Component
- Chips & Delivery Schedule
- App Entry & Typography
- Vietnamese Formatters
- Order Items Card
- New Order Form Sections
- Auth Step Content
- New Order Design Screenshot
- Flow Layout
- Quantity Stepper
- SwiftData Template Leftover
- Money Field Row
- UI Tests
- Segmented Picker
- Primary Button
- Card Status Enum
- Spacing Tokens
- App Strings

## God Nodes (most connected - your core abstractions)
1. `NewOrderViewModel` - 50 edges
2. `Shop` - 40 edges
3. `Email` - 33 edges
4. `OrderDraft` - 28 edges
5. `OnboardingViewModel` - 26 edges
6. `NewOrderViewModelTests` - 23 edges
7. `OrderInput` - 22 edges
8. `AuthViewModel` - 21 edges
9. `TodayViewModel` - 20 edges
10. `DSFormRow` - 19 edges

## Surprising Connections (you probably didn't know these)
- `NewOrderViewModelTests` --calls--> `Shop`  [INFERRED]
  irisTests/Presentation/NewOrderViewModelTests.swift → iris/Domain/Shop/Shop.swift
- `TodayViewModelTests` --calls--> `Shop`  [INFERRED]
  irisTests/Presentation/TodayViewModelTests.swift → iris/Domain/Shop/Shop.swift
- `.body` --calls--> `DSFormSection`  [INFERRED]
  iris/Presentation/Auth/Components/AuthField.swift → iris/DS/Components/DSFormSection.swift
- `.body` --calls--> `DSRow`  [INFERRED]
  iris/Presentation/Order/Components/MoneyFieldRow.swift → iris/DS/Components/DSRow.swift
- `MockAuthRepository` --inherits--> `AuthRepository`  [EXTRACTED]
  irisTests/MockAuthRepository.swift → iris/Domain/Auth/AuthRepository.swift

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Sections of the New Order form** — screenshots_don_moi_full_customer_section, screenshots_don_moi_full_products_section, screenshots_don_moi_full_delivery_method_segmented, screenshots_don_moi_full_delivery_schedule_card, screenshots_don_moi_full_delivery_address_section, screenshots_don_moi_full_card_and_notes_section, screenshots_don_moi_full_payment_section, screenshots_don_moi_full_save_order_cta [EXTRACTED 1.00]
- **Delivery scheduling flow (method, date, time window, address)** — screenshots_don_moi_full_delivery_method_segmented, screenshots_don_moi_full_delivery_schedule_card, screenshots_don_moi_full_time_window_chips, screenshots_don_moi_full_delivery_address_section [INFERRED 0.85]

## Communities (28 total, 5 thin omitted)

### Community 0 - "Order Domain Models"
Cohesion: 0.05
Nodes (30): DeliveryMethod, delivery, pickup, DeliveryTimeWindow, .isValid, TimeOfDay, .minutesSinceMidnight, OrderDraft (+22 more)

### Community 1 - "Auth Login Flow"
Cohesion: 0.05
Nodes (18): InMemoryAuthRepository, AuthSession, Email, LoginCode, RequestLoginCodeUseCase, VerifyLoginCodeUseCase, AuthViewModel, .content (+10 more)

### Community 2 - "New Order ViewModel"
Cohesion: 0.07
Nodes (19): NewOrderViewModel, .canRemoveItems, .canSave, .endTimeDate, .input, .isTodaySelected, .isTomorrowSelected, .recipientLine (+11 more)

### Community 3 - "Today Tab & Order Use Cases"
Cohesion: 0.06
Nodes (19): CreateOrderUseCase, LoadTodaySummaryUseCase, TodaySummary, .isEmpty, DSEmptyState, .body, DSSummaryTile, .body (+11 more)

### Community 4 - "Onboarding Screen"
Cohesion: 0.07
Nodes (18): CreateShopUseCase, JoinShopUseCase, DSTonalButton, .body, OnboardingView, .createShopSection, .joinShopSection, OnboardingViewModel (+10 more)

### Community 5 - "Shop Repository & Invite Code"
Cohesion: 0.08
Nodes (9): InMemoryShopRepository, InviteCode, Shop, ShopDraft, .canCreateShop, .canJoinShop, InviteCodeTests, ShopDraftTests (+1 more)

### Community 6 - "App Composition Root"
Cohesion: 0.07
Nodes (17): AppContainer, AppSessionStore, RootView, .body, AuthRepository, OrderRepository, ShopRepository, irisApp (+9 more)

### Community 7 - "In-Memory Repositories"
Cohesion: 0.09
Nodes (7): Foundation, iris, InMemoryOrderRepository, Order, irisTests, Observation, Testing

### Community 8 - "Domain Error Types"
Cohesion: 0.07
Nodes (18): AuthError, codeExpired, invalidCode, invalidEmail, OrderError, depositExceedsTotal, discountExceedsTotal, endTimeNotAfterStart (+10 more)

### Community 9 - "Auth View & Text Components"
Cohesion: 0.10
Nodes (12): DSErrorBanner, .body, DSTextButton, .body, AuthView, .body, .stepForm, .stepTransition (+4 more)

### Community 10 - "Form Row Component"
Cohesion: 0.13
Nodes (5): DSFormRow, .body, .field, InputTraits, .isMultiline

### Community 11 - "Chips & Delivery Schedule"
Cohesion: 0.15
Nodes (6): DSChip, DeliveryScheduleCard, .body, .dateRow, .timeSlotRow, .customerSection

### Community 12 - "App Entry & Typography"
Cohesion: 0.18
Nodes (6): DSRow, .body, Font, .money, SwiftData, SwiftUI

### Community 13 - "Vietnamese Formatters"
Cohesion: 0.20
Nodes (4): .remainingText, .totalText, AppFormatters, .dateLine

### Community 14 - "Order Items Card"
Cohesion: 0.14
Nodes (8): DSActionRow, .body, Style, destructive, tinted, OrderItemsCard, .body, .productsSection

### Community 15 - "New Order Form Sections"
Cohesion: 0.19
Nodes (8): DSFormCard, .body, DSFormSection, .body, NewOrderView, .notesSection, .paymentSection, .recipientSection

### Community 16 - "Auth Step Content"
Cohesion: 0.14
Nodes (8): AuthStepContent, InputKind, email, oneTimeCode, AuthField, .body, .keyboardType, .textContentType

### Community 17 - "New Order Design Screenshot"
Cohesion: 0.19
Nodes (11): Card Message & Notes Section (Thiệp & ghi chú), Customer Section (Khách đặt: name, phone), Delivery Address Section (Giao tới: Địa chỉ, Người nhận là người đặt / Đổi), Delivery Method Segmented Control (Giao tận nơi / Khách tới lấy), Delivery Schedule Card (Ngày: Hôm nay/Mai/date; Khung giờ chips; Từ giờ/Đến giờ), New Order Screen (Đơn mới), Order Source Chips (Zalo, Messenger, TikTok, Instagram, Gọi điện, Tại tiệm, Khác), Payment Section (Thanh toán: Phí ship, Giảm giá, Khách cọc, Tổng đơn, Còn lại) (+3 more)

### Community 20 - "SwiftData Template Leftover"
Cohesion: 0.25
Nodes (3): ContentView, .body, Item

### Community 21 - "Money Field Row"
Cohesion: 0.32
Nodes (3): MoneyFieldRow, .body, .text

### Community 23 - "Segmented Picker"
Cohesion: 0.29
Nodes (5): .body, DSSegmentedPicker, .body, DSFont, .deliverySection

### Community 24 - "Primary Button"
Cohesion: 0.29
Nodes (3): DSPrimaryButton, .body, .footer

### Community 25 - "Card Status Enum"
Cohesion: 0.33
Nodes (5): CardStatus, active, cancelled, done, late

## Knowledge Gaps
- **90 isolated node(s):** `.body`, `active`, `late`, `done`, `cancelled` (+85 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 219 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Shop` connect `Shop Repository & Invite Code` to `Order Domain Models`, `New Order ViewModel`, `Today Tab & Order Use Cases`, `Onboarding Screen`, `App Composition Root`, `In-Memory Repositories`?**
  _High betweenness centrality (0.177) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `NewOrderViewModel` (e.g. with `.addAndRemoveItems()` and `.customTimeSelectsNoPreset()`) actually correct?**
  _`NewOrderViewModel` has 4 INFERRED edges - model-reasoned connections that need verification._
- **What connects `.body`, `active`, `late` to the rest of the system?**
  _90 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Order Domain Models` be split into smaller, more focused modules?**
  _Cohesion score 0.0517503805175038 - nodes in this community are weakly interconnected._
- **Why does `NewOrderViewModel` connect `New Order ViewModel` to `Order Domain Models`, `Today Tab & Order Use Cases`, `Shop Repository & Invite Code`, `In-Memory Repositories`, `Domain Error Types`, `Chips & Delivery Schedule`, `Vietnamese Formatters`, `New Order Form Sections`?**
  _High betweenness centrality (0.175) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Shop` (e.g. with `NewOrderViewModelTests` and `TodayViewModelTests`) actually correct?**
  _`Shop` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Should `Auth Login Flow` be split into smaller, more focused modules?**
  _Cohesion score 0.05311871227364185 - nodes in this community are weakly interconnected._