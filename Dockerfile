# FROM nvcr.io/nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04
# FROM nvcr.io/nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
FROM nvcr.io/nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
# FROM nvcr.io/nvidia/cuda:10.0-cudnn7-runtime-ubuntu18.04

# Setup Environment Variable
ENV cvVersionChoice=1
ENV cvVersion="3.4.0"
ENV cwd="/home/"

WORKDIR $cwd

# RUN apt-get update \
  # && apt-get install -y software-properties-common
  # && add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"

RUN apt-get update
    # apt-get remove -y \
    # x264 libx264-dev

RUN apt-get install -y \
    software-properties-common \
    build-essential \
    checkinstall \
    cmake \
    pkg-config \
    yasm \
    git \
    vim \
    curl \
    gfortran \
    libjpeg8-dev \
    # libjasper1 \
    # libjasper-dev \
    libpng-dev \
    # libpng12-dev \
    libtiff5-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libdc1394-22-dev \
    libxine2-dev \
    libv4l-dev

RUN cd /usr/include/linux && \
    ln -s -f ../libv4l1-videodev.h videodev.h && \
    cd $cwd

RUN apt-get install -y \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgtk2.0-dev \
    libtbb-dev \
    qt5-default \
    libatlas-base-dev \
    libfaac-dev \
    libmp3lame-dev \
    libtheora-dev \
    libvorbis-dev \
    libxvidcore-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libavresample-dev \
    x264 \
    v4l-utils \
    libprotobuf-dev \
    protobuf-compiler \
    libgoogle-glog-dev \
    libgflags-dev \
    libgphoto2-dev \
    libeigen3-dev \
    libhdf5-dev \
    doxygen

RUN apt-get install -y build-essential python3-dev python3-pip 
# RUN apt-get install -y python3-testresources
RUN apt-get clean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*


RUN cd /usr/local/bin \
    && ln -s /usr/bin/python3 python \
    && pip3 install --no-cache-dir --upgrade pip

# RUN python3 -m pip install pip --upgrade
# RUN python3 -m pip install wheel
# RUN pip3 install -U numpy
# RUN python3 -m pip uninstall -y pip && \
#     apt install -y python3-pip --reinstall
# RUN python3 -m pip install -U jupyter jupyterhub==0.8.1 notebook

RUN pip3 install --no-cache-dir numpy \
    scipy \
    matplotlib \
    scikit-image \
    scikit-learn \
    ipython \
    ipykernel \
    plotly \
    jupyter
# RUN python3 -m ipykernel install --name OpenCV-$cvVersion-py3

RUN git clone https://github.com/opencv/opencv.git && \
    cd opencv && \
    git checkout $cvVersion && \
    cd ..

RUN git clone https://github.com/opencv/opencv_contrib.git && \
    cd opencv_contrib && \
    git checkout $cvVersion && \
    cd ..

RUN cd opencv && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DINSTALL_C_EXAMPLES=ON \
    -DWITH_TBB=ON \
    -DWITH_V4L=ON \
    -DWITH_QT=ON \
    -DWITH_OPENGL=ON \
    -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
    -DBUILD_EXAMPLES=ON \
    -D CUDA_FAST_MATH=1 \
    -D WITH_CUBLAS=ON \
    -D WITH_CUDA=ON \
    -D WITH_NVCUVID=ON \
    -D CUDA_NVCC_FLAGS="-D_FORCE_INLINES" \
    -D BUILD_opencv_cudacodec=ON \
    -D PYTHON_EXECUTABLE=/usr/bin/python3 \
    .. && \
    make -j10 && make install && \
    cd ..

RUN rm -r opencv && rm -r opencv_contrib

RUN /bin/sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf'
RUN ldconfig

ADD retroyolo /home/darknet
RUN cd darknet &&\
    make -j8

ENV PATH="/home/darknet:${PATH}"
