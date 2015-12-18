//
//  JSONError.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 16.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

public enum JSONError: ErrorType {
    case InvalidType(path: KeyPath, expected: Any.Type, value: AnyObject)
    case MissingKey(path: KeyPath)
    case Multiple([ErrorType])

    public var allErrors: [ErrorType] {
        guard case let .Multiple(errs) = self else { return [self] }
        return errs
    }

    private func addErrors(others: [ErrorType]) -> JSONError {
        guard case let .Multiple(errs) = self else {
            return .Multiple([self] + others)
        }

        return .Multiple(errs + others)
    }
}

public extension ErrorType {
    func mergeWith(other: ErrorType) -> JSONError {
        switch (self, other) {
            case let (a as JSONError, b as JSONError):
                return .Multiple(a.allErrors + b.allErrors)

            case let (a as JSONError, _):
                return .Multiple(a.allErrors + [other])

            case let (_, b as JSONError):
                return .Multiple([self] + b.allErrors)

            default: return .Multiple([self, other])
        }
    }
}
