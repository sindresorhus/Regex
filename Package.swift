// swift-tools-version:6.1
import PackageDescription

let package = Package(
	name: "Regex",
	platforms: [
		.macOS(.v10_15),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "Regex",
			targets: [
				"Regex"
			]
		)
	],
	targets: [
		.target(
			name: "Regex"
		),
		.testTarget(
			name: "RegexTests",
			dependencies: [
				"Regex"
			]
		)
	]
)
