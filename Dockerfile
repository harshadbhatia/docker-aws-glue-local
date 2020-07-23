FROM centos

ENV MAVEN=https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-common/apache-maven-3.6.0-bin.tar.gz
ENV SPARK=https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-1.0/spark-2.4.3-bin-hadoop2.8.tgz
ENV GLUE=https://github.com/awslabs/aws-glue-libs.git

RUN mkdir app
RUN yum install -y python3 java-1.8.0-openjdk java-1.8.0-openjdk-devel tar git wget zip

RUN ln -s /usr/bin/python3 /usr/bin/python
RUN ln -s /usr/bin/pip3 /usr/bin/pip
RUN pip install pandas boto3 pynt

WORKDIR ./app
RUN git clone -b glue-1.0 $GLUE

RUN wget $SPARK
RUN wget $MAVEN

RUN tar zxfv apache-maven-3.6.0-bin.tar.gz
RUN tar zxfv spark-2.4.3-bin-hadoop2.8.tgz
RUN rm spark-2.4.3-bin-hadoop2.8.tgz apache-maven-3.6.0-bin.tar.gz

RUN mv $(rpm -q -l java-1.8.0-openjdk-devel | grep "/bin$" | rev | cut -d"/" -f2- |rev) /usr/lib/jvm/jdk
ENV SPARK_HOME /app/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8
ENV MAVEN_HOME /app/apache-maven-3.6.0
ENV JAVA_HOME /usr/lib/jvm/jdk
ENV GLUE_HOME /app/aws-glue-libs
ENV PATH $PATH:$MAVEN_HOME/bin:$SPARK_HOME/bin:$JAVA_HOME/bin:$GLUE_HOME/bin
RUN sh /app/aws-glue-libs/bin/glue-setup.sh

RUN sed -i '/mvn -f/a rm /glue/aws-glue-libs/jarsv1/netty-*' /app/aws-glue-libs/bin/glue-setup.sh
RUN sed -i '/mvn -f/a rm /glue/aws-glue-libs/jarsv1/javax.servlet-3.*' /app/aws-glue-libs/bin/glue-setup.sh
RUN yum clean all
RUN rm -rf /var/cache/yum

RUN pip install jupyter-spark
RUN jupyter serverextension enable --py jupyter_spark
RUN jupyter nbextension install --py jupyter_spark
RUN jupyter nbextension enable --py jupyter_spark
RUN jupyter nbextension enable --py widgetsnbextension

EXPOSE 4040

CMD ["bash"]