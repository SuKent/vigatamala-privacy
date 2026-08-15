// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RuleConverter",
    platforms: [.macOS(.v13)],   // 只約束 Apple 平台;Linux(CI)不受影響
    products: [.executable(name: "RuleConverter", targets: ["RuleConverter"])],
    targets: [.executableTarget(name: "RuleConverter", swiftSettings: [.swiftLanguageMode(.v5)])]
)
