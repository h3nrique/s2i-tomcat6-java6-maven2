FROM centos/s2i-base-centos7

EXPOSE 8080

ENV TOMCAT_VERSION=6.0.53 \
    TOMCAT_MAJOR=6 \
    MAVEN_VERSION=2.2.1 \
    TOMCAT_DISPLAY_VERSION=6 \
    CATALINA_HOME=/tomcat \
    JAVA_VERSION="6" \
    JAVA_UPDATE="45" \
    JAVA_HOME="/usr/lib/jvm/default-jvm"

LABEL io.k8s.description="Platform for building with Maven2 and running Java 6 applications on Tomcat 6." \
      sun.java.version="6u45" \
      apache.maven.version="2.2.1" \
      apache.tomcat.version="6.0.53" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="s2i,builder,tomcat,tomcat6,java,java6,maven,maven2" \
      io.openshift.s2i.destination="/opt/s2i/destination"

ADD java-installer/jdk-6u45-linux-x64.* /tmp/

# Install Maven, Tomcat, Java
RUN INSTALL_PKGS="tar unzip bc which lsof" && \
    cd /tmp && \
    sha256sum -c jdk-6u45-linux-x64.bin.sha256 && \
    yum repolist && \
    yum install $INSTALL_PKGS -y && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    sh "./jdk-6u45-linux-x64.bin" && \
    mkdir -p "/usr/lib/jvm" && \
    mv "/tmp/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" "/usr/lib/jvm/java-${JAVA_VERSION}-oracle" && \
    ln -s "/usr/lib/jvm/java-${JAVA_VERSION}-oracle" "$JAVA_HOME" && \
    ln -s "$JAVA_HOME/bin/"* "/usr/bin/" && \
    rm -rfv /tmp/jdk-6u45-linux-x64.* \
           "$JAVA_HOME/"*src.zip \
           "$JAVA_HOME/lib/missioncontrol" \
           "$JAVA_HOME/lib/visualvm" \
           "$JAVA_HOME/lib/"*javafx* \
           "$JAVA_HOME/jre/lib/plugin.jar" \
           "$JAVA_HOME/jre/lib/ext/jfxrt.jar" \
           "$JAVA_HOME/jre/bin/javaws" \
           "$JAVA_HOME/jre/lib/javaws.jar" \
           "$JAVA_HOME/jre/lib/desktop" \
           "$JAVA_HOME/jre/plugin" \
           "$JAVA_HOME/jre/lib/"deploy* \
           "$JAVA_HOME/jre/lib/"*javafx* \
           "$JAVA_HOME/jre/lib/"*jfx* \
           "$JAVA_HOME/jre/lib/amd64/libdecora_sse.so" \
           "$JAVA_HOME/jre/lib/amd64/"libprism_*.so \
           "$JAVA_HOME/jre/lib/amd64/libfxplugins.so" \
           "$JAVA_HOME/jre/lib/amd64/libglass.so" \
           "$JAVA_HOME/jre/lib/amd64/libgstreamer-lite.so" \
           "$JAVA_HOME/jre/lib/amd64/"libjavafx*.so \
           "$JAVA_HOME/jre/lib/amd64/"libjfx*.so \
           "$JAVA_HOME/jre/bin/keytool" \
           "$JAVA_HOME/jre/bin/orbd" \
           "$JAVA_HOME/jre/bin/pack200" \
           "$JAVA_HOME/jre/bin/policytool" \
           "$JAVA_HOME/jre/bin/rmid" \
           "$JAVA_HOME/jre/bin/rmiregistry" \
           "$JAVA_HOME/jre/bin/servertool" \
           "$JAVA_HOME/jre/bin/tnameserv" \
           "$JAVA_HOME/jre/bin/unpack200" \
           "$JAVA_HOME/jre/lib/jfr.jar" \
           "$JAVA_HOME/jre/lib/jfr" \
           "$JAVA_HOME/jre/lib/oblique-fonts" && \
    (curl -v https://archive.apache.org/dist/maven/maven-2/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    ln -sf /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && \
    mkdir -p /tomcat && \
    (curl -v https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz | tar -zx --strip-components=1 -C /tomcat) && \
    mkdir -p /opt/s2i/destination

# Add s2i tomcat customizations
ADD ./contrib/settings.xml $HOME/.m2/

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

RUN chown -R 1001:0 /tomcat && chown -R 1001:0 $HOME && \
    chmod -R ug+rwx /tomcat && \
    chmod -R g+rw /opt/s2i/destination

USER 1001

CMD $STI_SCRIPTS_PATH/usage
