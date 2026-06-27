import groovy.lang.Closure
import groovy.lang.GroovySystem
import org.gradle.api.artifacts.dsl.RepositoryHandler

GroovySystem.getMetaClassRegistry()
    .getMetaClass(RepositoryHandler::class.java)
    .registerInstanceMethod("jcenter", object : Closure<Any>(null) {
        fun doCall(): Any? {
            val handler = delegate as? RepositoryHandler
            return handler?.mavenCentral()
        }
    })

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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
