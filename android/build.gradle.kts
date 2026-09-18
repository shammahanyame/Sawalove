allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val installedNdkVersion = "27.0.12077973"

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { androidExtension ->
            runCatching {
                androidExtension.javaClass
                    .getMethod("setNdkVersion", String::class.java)
                    .invoke(androidExtension, installedNdkVersion)
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
