ARG TAG=latest
FROM continuumio/miniconda3:$TAG

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        git \
        locales \
        sudo \
        build-essential \
        dpkg-dev \
        wget \
        openssh-server \
        ca-certificates \
        netbase\
        tzdata \
        nano \
        software-properties-common \
        python3-venv \
        python3-tk \
        pip \
        bash \
        git \
        ncdu \
        net-tools \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        unzip \
        htop \
        pkg-config \
        libcairo2-dev \
        libgoogle-perftools4 libtcmalloc-minimal4  \
    && rm -rf /var/lib/apt/lists/*

# Setting up locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# RUN service ssh start
EXPOSE 5111

# Create user:
RUN groupadd --gid 1020 gpt-group
RUN useradd -rm -d /home/gpt-user -s /bin/bash -G users,sudo,gpt-group -u 1000 gpt-user

# Update user password:
RUN echo 'gpt-user:admin' | chpasswd

RUN mkdir /home/gpt-user/gpt

RUN cd /home/gpt-user/gpt

RUN python3 -m pip install torch torchvision torchaudio

# Clone the repository
RUN git clone https://github.com/PromtEngineer/localGPT.git /home/gpt-user/gpt

RUN chmod 777 /home/gpt-user/gpt

ADD ./SOURCE_DOCUMENTS /home/gpt-user/gpt/SOURCE_DOCUMENTS

#RUN mkdir /home/gpt-user/gpt/models

RUN cd /home/gpt-user/gpt

# Install the dependencies
RUN python3 -m pip install -r /home/gpt-user/gpt/requirements.txt

# Then install AutoGPTQ - if you want to run quantized models for GPU:
RUN git clone https://github.com/PanQiWei/AutoGPTQ.git /home/gpt-user/gpt/AutoGPTQ && \
    cd /home/gpt-user/gpt/AutoGPTQ/ && \
    git checkout v0.2.2 && \
    python3 -m pip install .

# Команда для загрузки новых данных: RUN python3 ingest.py
# Укажите тип устройства(cuda / cpu):
# RUN python3 ingest.py --device_type cuda

# Для выполнения запроса локально(без ui из консоли):
# python run_localGPT.py / python run_localGPT.py --device_type cpu
# debug: CMAKE_ARGS="-DLLAMA_METAL=вкл" FORCE_CMAKE=1 pip install -U llama-cpp-python --no-cache-dir

# Запуск скрипта API:
#RUN cd /home/gpt-user/gpt/ && \
#    python3 run_localGPT_API.py

# Preparing for login
ENV HOME home/gpt-user/gpt/localGPTUI/
WORKDIR ${HOME}

CMD python3 localGPTUI.py

# Запуск интерфейса:
# http://localhost:5111/

# Docker:
# docker build -t localgpt .
# docker run -dit --name localgpt -p 5111:5111 -v D:/Develop/NeuronNetwork/llama_cpp/llama_cpp_java/SOURCE_DOCUMENTS:/home/gpt-user/gpt/SOURCE_DOCUMENTS --gpus all --restart unless-stopped localgpt:latest

# debug: docker container attach localgpt

#