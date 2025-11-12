import ProjectDescription

let organizationName = "xoul.kimkhuna" // 파일 경로에서 유추
let bundleIdBase = "kr.\(organizationName).Orbit"


let project = Project(
    name: "Orbit",
    organizationName: organizationName,
    targets: [
        // 1. 메인 앱 타겟 (Orbit)
        .target(
            name: "Orbit",
            destinations: .iOS,
            product: .app,
            bundleId: bundleIdBase,
            infoPlist: .default,
            sources: ["Orbit/**"],
            resources: [
                "Orbit/Assets.xcassets/**",
                "Orbit/Preview Content/**"
            ],
            dependencies: []
        ),
        
        // 2. 유닛 테스트 타겟 (OrbitTests)
                .target(
                    name: "OrbitTests",
                    destinations: .iOS,
                    product: .unitTests,
                    bundleId: "\(bundleIdBase)Tests",
                    infoPlist: .default,
                    sources: ["OrbitTests/**"],
                    resources: [],
                    dependencies: [
                        .target(name: "Orbit")
                    ]
                ),

                // 3. UI 테스트 타겟 (OrbitUITests)
                .target(
                    name: "OrbitUITests",
                    destinations: .iOS,
                    product: .uiTests,
                    bundleId: "\(bundleIdBase)UITests",
                    infoPlist: .default,
                    sources: ["OrbitUITests/**"],
                    resources: [],
                    dependencies: [
                        .target(name: "Orbit")
                    ]
                )
    ]
)
