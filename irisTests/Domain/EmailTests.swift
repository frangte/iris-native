//
//  EmailTests.swift
//  irisTests
//
//  Created by SonnyHoang on 12/11/26.
//

import Testing
@testable import iris

struct EmailTests {
    @Test(arguments: ["ten@email.com", "  a@b.co  ", "x.y@sub.domain.vn"])
    func acceptsValidAddresses(raw: String) {
        #expect(Email(raw) != nil)
    }

    @Test(arguments: ["", "ten", "@email.com", "ten@", "ten@email", "ten@email.", "ten@.com"])
    func rejectsInvalidAddresses(raw: String) {
        #expect(Email(raw) == nil)
    }

    @Test func trimsWhitespace() {
        #expect(Email("  ten@email.com\n")?.value == "ten@email.com")
    }
}

struct LoginCodeTests {
    @Test func acceptsSixDigits() {
        #expect(LoginCode("123456")?.value == "123456")
    }

    @Test(arguments: ["", "12345", "1234567", "12a456"])
    func rejectsOtherInput(raw: String) {
        #expect(LoginCode(raw) == nil)
    }
}
