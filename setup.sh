# configure proxy to download packages, note that proxy must be disabled before gateway starts
export http_proxy=http://child-prc.intel.com:913/
export https_proxy=http://child-prc.intel.com:913/


# install conda and jupyter packages
export  CONDA_HOME=/opt/work/conda
wget https://repo.continuum.io/miniconda/Miniconda3-4.3.31-Linux-x86_64.sh
/bin/bash Miniconda3-4.3.31-Linux-x86_64.sh -f -b -p ${CONDA_HOME}
export JAVA_HOME=/opt/jdk1.8.0_152
export PATH=${JAVA_HOME}/bin:${CONDA_HOME}/bin:${PATH}
export PATH=${CONDA_HOME}/bin:${PATH}

conda config --system --prepend channels conda-forge && \
conda config --system --set auto_update_conda false && \
conda config --system --set show_channel_urls true && \
conda update --all --quiet --yes && \
conda clean -tipsy

conda install -y -c conda-forge jupyter_enterprise_gateway
conda install -y -c conda-forge jupyterhub


# install kernels
wget https://github.com/jupyter/enterprise_gateway/releases/download/v1.1.1/jupyter_enterprise_gateway_kernelspecs-1.1.1.tar.gz
mkdir -p /usr/local/share/jupyter/kernels
tar -zxvf jupyter_enterprise_gateway_kernelspecs-1.1.1.tar.gz -C /usr/local/share/jupyter/kernels
export KERNELS_FOLDER=/usr/local/share/jupyter/kernels


# install spark
wget http://archive.apache.org/dist/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz
tar -xf spark-2.4.0-bin-hadoop2.7.tgz -C /opt/work

export SPARK_HOME=/opt/work/spark-2.4.0-bin-hadoop2.7
export PATH=/opt/work/hadoop-2.7.2/bin:${CONDA_HOME}/bin:${PATH}
export HADOOP_HOME=/opt/work/hadoop-2.7.2


# add following to spark-env.sh
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop


# generate config and use backup config to cover it
jupyter enterprisegateway --generate-config
jupyterhub --generate-config
# use kernel.json to cover the old one


# install and enable nb2kg (an extension for connecting kernel)
pip install "git+https://github.com/jupyter-incubator/nb2kg.git#egg=nb2kg"
jupyter serverextension enable --py nb2kg --sys-prefix


# start enterprise gateway and jupyterhub
jupyter enterprisegateway
jupyterhub
