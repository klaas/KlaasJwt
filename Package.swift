// swift-tools-version:5.0
import PackageDescription

let package = Package(
	name: "KlaasJwt",
	platforms: [
		.macOS(.v10_13),
	],
	dependencies: [
		.package(url: "https://github.com/IBM-Swift/Swift-JWT.git", from: "3.5.0"),
		.package(url: "https://github.com/klaas/CupertinoJWT", .branch("master")),
		.package(url: "https://github.com/klaas/ParkBenchCommon", from: "2.0.0"),
		.package(url: "https://github.com/klaas/Pogging.git", from: "2.0.0"),
		.package(url: "https://github.com/klaas/Guaka.git", .branch("master_neu")),
	],
	targets: [
		.target(name: "qjwt", dependencies: ["ParkBench", "Pogging", "Guaka", "SwiftJWT", "CupertinoJWT"]),
	],
	swiftLanguageVersions: [.v5]
)
