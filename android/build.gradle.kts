plugins {
    // No Firebase plugins needed
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ مجلد build الموحد لكل المشروع (اختياري لكنه جيد لو أردت تنظيم الناتج)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

// ✅ إعادة توجيه build dir لكل subproject (مثل :app)
subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    // ✅ تأكد من تقييم :app أولًا إذا كانت بعض الـ Plugins تعتمد عليه
    evaluationDependsOn(":app")
}

// ✅ مهمة clean لتنظيف ناتج البناء بالكامل
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
