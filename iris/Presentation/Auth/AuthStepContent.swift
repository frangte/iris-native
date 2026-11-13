//
//  AuthStepContent.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Display data for one login step.
/// `AuthView` renders this struct and never needs to know which step is active.
struct AuthStepContent: Equatable {
    /// What the user types in this step; drives keyboard and autofill of the text field.
    enum InputKind {
        case email
        case oneTimeCode
    }

    let inputKind: InputKind
    let fieldLabel: String
    let placeholder: String
    let footer: String?
    let primaryTitle: String
    /// Secondary action under the primary button. `nil` when the step has none.
    let secondaryTitle: String?
}
