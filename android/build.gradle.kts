buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
    }
}

allprojects {
    repositories {
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        google()
        mavenCentral()
    }
}

subprojects {
    project.buildscript {
        configurations.all {
            resolutionStrategy {
                force("com.android.tools.build:gradle:8.11.1")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
