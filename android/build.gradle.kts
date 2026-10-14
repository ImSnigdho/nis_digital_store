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
    afterEvaluate {
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                val method = android.javaClass.getMethod("setCompileSdkVersion", Integer.TYPE)
                method.invoke(android, 36)
            } catch (_: Exception) {
                try {
                    val method = android.javaClass.getMethod("setCompileSdk", java.lang.Integer::class.java)
                    method.invoke(android, 36)
                } catch (_: Exception) {}
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
