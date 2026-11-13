//
//  ShopTests.swift
//  irisTests
//
//  Created by SonnyHoang on 12/11/26.
//

import Testing
@testable import iris

struct InviteCodeTests {
    @Test(arguments: ["K7M2QX", " k7m2qx ", "abc123"])
    func acceptsSixAlphanumerics(raw: String) {
        #expect(InviteCode(raw) != nil)
    }

    @Test func normalizesToUppercase() {
        #expect(InviteCode(" k7m2qx ")?.value == "K7M2QX")
    }

    @Test(arguments: ["", "K7M2Q", "K7M2QX1", "K7M-2Q", "K7 2QX"])
    func rejectsOtherInput(raw: String) {
        #expect(InviteCode(raw) == nil)
    }
}

struct ShopDraftTests {
    @Test func requiresName() {
        #expect(ShopDraft(name: "  ", phone: "", address: "") == nil)
    }

    @Test func trimsFieldsAndDropsEmptyOptionals() {
        let draft = ShopDraft(name: " Mộc ", phone: " ", address: " 1 Lê Lợi ")

        #expect(draft?.name == "Mộc")
        #expect(draft?.phone == nil)
        #expect(draft?.address == "1 Lê Lợi")
    }
}
