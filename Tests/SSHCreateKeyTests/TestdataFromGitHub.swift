//
//  TestdataFromGitHub.swift
//  RsyncArguments
//
//  Created by Thomas Evensen on 05/08/2024.
//

import Foundation

struct TestdataFromGitHub {
    let urlSession = URLSession.shared
    let jsonDecoder = JSONDecoder()

    func loadanddecodestringdata<T: Codable>(_ t: T.Type, fromwhere: String) async throws -> T? {
        if let url = URL(string: fromwhere) {
            let (data, _) = try await urlSession.gettestdata(for: url)
            return try jsonDecoder.decode(T.self, from: data)
        } else {
            return nil
        }
    }
    
    func loadanddecodearraydata<T: Codable>(_ t: T.Type, fromwhere: String) async throws -> [T]? {
        if let url = URL(string: fromwhere) {
            let (data, _) = try await urlSession.gettestdata(for: url)
            return try jsonDecoder.decode([T].self, from: data)
        } else {
            return nil
        }
    }
}

public extension URLSession {
    func gettestdata(for url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url)
    }
}
