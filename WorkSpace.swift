import ProjectDescription

let workspace = Workspace(
    name: "Orbit",
    projects: [
        "." // 현재 폴더(Project.swift)에 있는 프로젝트를 포함
    ],
    additionalFiles: [
        "Project.swift",
        "Workspace.swift"
    ]
)
