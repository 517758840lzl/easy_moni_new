// 为项目和 Flutter included build 注入国内 Maven 镜像，避免 Android Gradle Plugin 解析时直连失败。
fun RepositoryHandler.addProjectMirrors() {
    maven { url = uri("https://maven.aliyun.com/repository/google") }
    maven { url = uri("https://maven.aliyun.com/repository/central") }
    maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
    google()
    mavenCentral()
    gradlePluginPortal()
}

settingsEvaluated {
    pluginManagement {
        repositories {
            addProjectMirrors()
        }
    }

    dependencyResolutionManagement {
        repositories {
            addProjectMirrors()
        }
    }
}
