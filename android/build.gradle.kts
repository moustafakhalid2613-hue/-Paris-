allprojects {
    repositories {
        google()
        mavenCentral()
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

// تعيين namespace للمكتبات القديمة بدون استخدام afterEvaluate
subprojects {
    plugins.whenPluginAdded {
        if (this is com.android.build.gradle.AppPlugin || this is com.android.build.gradle.LibraryPlugin) {
            val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null && android.namespace == null) {
                android.namespace = "com.example.${project.name.replace("-", "_")}"
            }
        }
    }
}

tasks.register("clean") {
    delete(rootProject.layout.buildDirectory)
}
