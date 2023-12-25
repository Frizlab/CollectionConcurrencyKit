// swift-tools-version:5.5
import PackageDescription


let package = Package(
	name: "CollectionConcurrencyKit",
	platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13)],
	products: [
		.library(
			name: "CollectionConcurrencyKit",
			targets: ["CollectionConcurrencyKit"]
		)
	],
	targets: [
		.target(
			name: "CollectionConcurrencyKit",
			path: "Sources"
		),
		.testTarget(
			name: "CollectionConcurrencyKitTests",
			dependencies: ["CollectionConcurrencyKit"],
			path: "Tests"
		)
	]
)
