//

import Foundation
import ParkBench
import Pogging
import Guaka
import SwiftJWT
import CupertinoJWT

class Commands: LogCompetent {
	static var defaultLogTag = LogTag(code: "AppleMusicCommands", minimumLevel: .debug)

	// MARK: - 🔴🔴🔴🔴🔴 commands 🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴

	func createCommands() -> [Command] {
		let res: [Command] = [
			Command(usage: "generateToken team-id key-id key-file.p8", shortMessage: "search apple music for songs", flags: [
				Flag(shortName: "t", longName: "expiryDuration", value: 60 * 24, description: "expiryDuration in minutes (defaults to 1440 minutes = 1 day)."),
			], run: generateTokenCommand),
		]

		res[res.firstIndex { try! $0.name() == "generateToken" }!].aliases = ["g"]

		return res
	}

	func generateTokenCommand(command: Command, flags: Flags, args: [String]) {
		command.guard(args, countIs: 3)

		// from https://developer.apple.com/documentation/applemusicapi/getting_keys_and_creating_tokens
		// After you create the token, sign it with your MusicKit private key. Then encrypt the token using the Elliptic Curve Digital Signature Algorithm (ECDSA) with the P-256 curve and the SHA-256 hash algorithm. Specify the value ES256 in the algorithm header key (alg).

		//	{
		//		"alg":"ES256",
		//		"typ":"JWT",
		//		"kid":"FQ4GB7GK43"
		//	}

		//	{
		//		"iss":"JJXPJWACWB",
		//		"iat":1560679397,
		//		"exp":1560722597
		//	}

		let teamId = args[0]
		let keyId = args[1]
		let keyFile = URL(fileURLWithPath: args[2])
		let expiryDuration = flags.getInt(name: "expiryDuration")!

		let key_pem: String

		do {
			key_pem = try String(contentsOf: keyFile)
		} catch {
			self.pog(.warning, "\(error.localizedDescription)")
			command.fail(statusCode: -1, errorMessage: error.localizedDescription)
		}

		let nowDate = Date()

		print("--------------------------------------------------------------------------------------")

		do {
			let myHeader = Header(kid: keyId)

			struct MyClaims: Claims {
				let iss: String
				let iat: Int
				let exp: Int
			}

			let nowDate_int: Int = Int(nowDate.timeIntervalSince1970.rounded())

			let myClaims = MyClaims(iss: teamId, iat: nowDate_int, exp: nowDate_int + expiryDuration * 60)
			var myJWT = SwiftJWT.JWT(header: myHeader, claims: myClaims)

			do {
				let token = try myJWT.sign(using: .es256(privateKey: key_pem.data(using: .utf8)!))
				print("(IBM-Swift-JWT):\n\t\(token)")
				print(token.tokenContent)
			} catch {
				self.pog(.warning, "\(error.localizedDescription)")
				self.pog(.warning, "\(error)")
			}
		}
		
		print("--------------------------------------------------------------------------------------")

		do {
			// Assign developer information and token expiration setting
			let jwt = CupertinoJWT.JWT(keyID: keyId, teamID: teamId, issueDate: nowDate, expireDuration: TimeInterval(expiryDuration * 60))

			do {
				let token = try jwt.sign(with: key_pem)
				print("(CupertinoJWT):\n\t\(token)")
				print(token.tokenContent)
				// Use the token in the authorization header in your requests connecting to Apple’s API server.
				// e.g. urlRequest.addValue(_ value: "bearer \(token)", forHTTPHeaderField field: "authorization")
			} catch {
				// Handle error
			}
		}

		print("--------------------------------------------------------------------------------------")
	}
}

extension String {
	var tokenContent: String {
		let comps = components(separatedBy: ".")
		let header = String(data: Data(base64Encoded_fill: comps[0]) ?? Data(), encoding: .utf8)!
		let payload = String(data: Data(base64Encoded_fill: comps[1]) ?? Data(), encoding: .utf8)!
		let signatureBase64 = comps[2]
		
		return """
		\tHeader:
		\t\t\(header)
		\tPayload:
		\t\t\(payload)
		\tSignature:
		\t\t\(signatureBase64)
		"""
	}
}
