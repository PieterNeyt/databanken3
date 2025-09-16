FROM quay.io/jupyter/pyspark-notebook

#ARG openjdk_version=17
ARG spark_version=4.0.0
ARG hadoop_version=3
ARG spark_download_url="https://archive.apache.org/dist/spark"
ARG delta_version=4.0.0	
ARG postgres_version=42.7.7

# Install delta-spark Python package
RUN pip install delta-spark==${delta_version}
RUN pip install findspark

USER root
RUN apt-get update && apt-get install -y maven

# Remove pre-installed Spark
#RUN rm -rf /usr/local/spark

# Download and extract Spark
#RUN wget -q ${spark_download_url}spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_version}.tgz -O /tmp/spark.tgz \
#    && tar -xzf /tmp/spark.tgz -C /usr/local \
#    && mv /usr/local/spark-${spark_version}-bin-hadoop${hadoop_version} /usr/local/spark \
#    && rm /tmp/spark.tgz
	
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$SPARK_HOME/bin:$PATH
ENV DELTA_VERSION=${delta_version}
ENV PYSPARK_SUBMIT_ARGS="--packages io.delta:delta-spark_2.13:${DELTA_VERSION} pyspark-shell"


# Download Delta Lake JAR
COPY pysparkjupyter/pom.xml /tmp/pom.xml
RUN mvn -f /tmp/pom.xml dependency:copy-dependencies -DoutputDirectory=/usr/local/spark/jars

# Set Spark config for Delta Lake
#ENV PYSPARK_SUBMIT_ARGS="--packages io.delta:delta-spark_2.13:${delta_version} pyspark-shell"

# docker run --detach -p 8888:8888 -p 4040:4040 -p 4041:4041 -v C:/DevProjects/Databricks/:/home/jovyan/ pysparkjupyter
