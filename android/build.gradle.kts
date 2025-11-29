allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val project = this
    project.buildDir = File(newBuildDir.asFile, project.name)
    project.evaluationDependsOn(":app")

    // --- FIX 1: Force Compile SDK 35 for all libraries (Fixes lStar error) ---
    val configureAndroid = {
        project.extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
            compileSdkVersion(35)
        }
    }

    if (project.state.executed) {
        configureAndroid()
    } else {
        project.afterEvaluate {
            configureAndroid()
        }
    }

    // --- FIX 2: Isar Namespace Fix ---
    if (project.name == "isar_flutter_libs") {
        project.pluginManager.withPlugin("com.android.library") {
            project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                namespace = "dev.isar.isar_flutter_libs"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}