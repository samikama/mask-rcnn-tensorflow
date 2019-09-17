FROM nvcr.io/nvidia/tensorflow:19.08-py3
WORKDIR /opt/tensorflow
RUN cd tensorflow-source && \
    wget https://github.com/aws-samples/mask-rcnn-tensorflow/releases/download/v0.0.0/NMSFix.co.patch && \
    patch -p1 < NMSFix.co.patch && \
    cd ..
RUN ./nvbuild.sh --python3.6
RUN apt-get update && \
    apt-get install -y libsm6 libxext6 libxrender-dev emacs-nox && \
    pip install opencv-python
RUN pip uninstall -y numpy && \
    pip uninstall -y numpy
RUN pip install --ignore-installed numpy==1.16.2
WORKDIR /
RUN apt-get update && \
    apt-get install -y libsm6 libxext6 libxrender-dev && \
    pip install opencv-python
RUN pip uninstall -y numpy && \
    pip uninstall -y numpy
RUN pip install --ignore-installed numpy==1.16.2
ARG BRANCH_NAME
RUN git clone https://github.com/aws-samples/mask-rcnn-tensorflow.git -b $BRANCH_NAME
COPY Patch.patch NVIDIA_Nsight_Systems_Linux_2019.5.1.58.deb   /mask-rcnn-tensorflow/
RUN chmod -R +w /mask-rcnn-tensorflow; cd /mask-rcnn-tensorflow ; git apply <Patch.patch
RUN pip install --ignore-installed -e /mask-rcnn-tensorflow/
