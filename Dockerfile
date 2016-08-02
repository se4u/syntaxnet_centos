FROM centos:7

RUN yum install -y java-1.8.0-openjdk-devel.x86_64 \
    which

ENV MAVEN_VERSION 3.3.9

RUN mkdir -p /usr/share/maven \
  && curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
      | tar -xzC /usr/share/maven --strip-components=1 \
        && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven

VOLUME /root/.m2

ENV JAVA_HOME /usr/lib/jvm/java

ENV M2HOME=/root/.m2/

ENV SYNTAXNETDIR=/opt/tensorflow PATH=$PATH:/root/bin

RUN mkdir -p $SYNTAXNETDIR \
    && cd $SYNTAXNETDIR \
    && yum install git zlib1g-dev file swig python2.7 python-dev -y \
    && yum install python-setuptools python-setuptools-devel -y \
    && easy_install pip \
    && pip install --upgrade pip \
    && pip install -U protobuf==3.0.0b2 \
    && pip install asciitree \
    && pip install numpy \
    && pip install git+https://github.com/se4u/rasengan.git \
    && curl -L https://github.com/bazelbuild/bazel/releases/download/0.2.2b/bazel-0.2.2b-installer-linux-x86_64.sh -o bazel-0.2.2b-installer-linux-x86_64.sh \
    && yum install unzip -y \
    && chmod +x bazel-0.2.2b-installer-linux-x86_64.sh \
    && ./bazel-0.2.2b-installer-linux-x86_64.sh --user \
    && git clone --recursive https://github.com/tensorflow/models.git \
    && cd $SYNTAXNETDIR/models/syntaxnet/tensorflow \
    && echo "\n\n\n" | ./configure \
    && yum autoremove -y \
    && yum clean all

RUN yum install gcc-c++ binutils-devel -y \
    && yum autoremove -y \
    && yum clean all 

RUN yum install python-devel zlib-devel -y && yum autoremove -y && yum clean all 

RUN cd $SYNTAXNETDIR/models/syntaxnet \
    && bazel test --genrule_strategy=standalone syntaxnet/... util/utf8/...

COPY server.py $SYNTAXNETDIR/models/syntaxnet/
COPY demo.sh   $SYNTAXNETDIR/models/syntaxnet/syntaxnet/
RUN pip install pexpect && git clone https://github.com/se4u/rasengan && cd rasengan && python setup.py develop

WORKDIR $SYNTAXNETDIR/models/syntaxnet

CMD [ "python", "server.py" ]

# COMMANDS to build and run
# ===============================
# mkdir build && cp Dockerfile build/ && cd build
# docker build -t syntaxnet .
# docker run syntaxnet
