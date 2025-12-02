import ProjectDescription

let organizationName = "xoul.kimkhuna" // 파일 경로에서 유추
let bundleIdBase = "kr.\(organizationName).Orbit"


let infoPlist: InfoPlist = .extendingDefault(with: [
    "UILaunchScreen": [
        "UIImageName": "",
    ],
    "NSCameraUsageDescription": "영수증 스캔을 위해 카메라 접근 권한이 필요합니다.",
])

let watchInfoPlist: InfoPlist = .extendingDefault(with: [
    "WKApplication": true,
    "WKCompanionAppBundleIdentifier": "\(bundleIdBase)",
    "UILaunchScreen": [
        "UIImageName": "",
    ],
])

let settings: Settings = .settings(base: [
    "CODE_SIGN_STYLE": "Automatic"
])

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
            deploymentTargets: .iOS("18.0"),
            infoPlist: infoPlist,
            sources: ["Orbit/**"],
            resources: [
                "Orbit/Assets.xcassets/**",
                "Orbit/Preview Content/**"
            ],
            dependencies: [
                .target(name: "Orbit-WatchOS Watch App")
            ],
            settings: settings
        ),
        
        // 2. 유닛 테스트 타겟 (OrbitTests)
        .target(
            name: "OrbitTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundleIdBase)Tests",
            deploymentTargets: .iOS("18.0"),
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
            deploymentTargets: .iOS("18.0"),
            sources: ["OrbitUITests/**"],
            resources: [],
            dependencies: [
                .target(name: "Orbit")
            ]
        ),
        
        .target(
            name: "Orbit-WatchOS Watch App",
            destinations: .watchOS,
            product: .app,
            bundleId: "\(bundleIdBase).watchkitapp",
            deploymentTargets: .watchOS("11.0"),
            infoPlist: watchInfoPlist,
            sources: [
                "Orbit-WatchOS Watch App/**",
                "Orbit/Sources/Common/Manager/ConnectivityManager.swift",
                "Orbit/Sources/Common/Enum/TransactionType.swift"
            ],
            resources: [],
            dependencies: []
        )
    ]
)
