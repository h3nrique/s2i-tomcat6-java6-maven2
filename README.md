# s2i Tomcat6 Java6- Maven2

S2I Image Builder for build Sun Java 6 applications using Apache Maven 2 and running on Apace Tomcat 6.

First Step
---
Before you build this image, it's necessary download Java 6 installer file (jdk-6u45-linux-x64.bin), put on java-installer directory and create sha256 file (user command `sha256sum jdk-6u45-linux-x64.bin > jdk-6u45-linux-x64.bin.sha256`).

Local Docker build
---
```bash
$ docker build -t h3nrique/s2i-tomcat6-java6-maven2:latest .
```

Local Test
---
```bash
$ s2i build https://github.com/h3nrique/systemprops.git h3nrique/s2i-tomcat6-java6-maven2:latest demoapp -e WAR_NAME=systemprops.war
$ docker run -p 8080:8080 demoapp
```

Deploy Builder on Openshift
---
```bash
$ oc new-build "https://github.com/h3nrique/s2i-tomcat6-java6-maven2.git" --name=s2i-tomcat6-java6-maven2 --strategy=docker
```
