FROM mcr.microsoft.com/dotnet/sdk:8.0

RUN apt-get update && \
    apt-get install -y \
        build-essential wget curl git libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev libffi-dev \
        libncursesw5-dev xz-utils tk-dev libgdbm-dev libnss3-dev \
        liblzma-dev uuid-dev openjdk-17-jdk jq && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

ENV PYTHON_VERSION=3.13.7

RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations --with-ensurepip=install && \
    make -j$(nproc) && \
    make altinstall && \
    cd .. && \
    rm -rf Python-${PYTHON_VERSION}*

RUN ln -s /usr/local/bin/python3.13 /usr/local/bin/python && \
    ln -s /usr/local/bin/pip3.13 /usr/local/bin/pip

WORKDIR /app

COPY for-dockerfile/repos.lock.json /app/
COPY for-dockerfile/requirements.lock /app/

RUN python3.13 -m venv /venv
ENV PATH=/venv/bin:$PATH

RUN pip install --upgrade pip && \
    pip install -r /app/requirements.lock

RUN DAFNY_REPO=$(jq -r '.dafny.repo' repos.lock.json) && \
    DAFNY_BRANCH=$(jq -r '.dafny.branch' repos.lock.json) && \
    DAFNY_COMMIT=$(jq -r '.dafny.commit' repos.lock.json) && \
    BOOGIE_BRANCH=$(jq -r '.boogie.branch' repos.lock.json) && \
    BOOGIE_COMMIT=$(jq -r '.boogie.commit' repos.lock.json) && \
    git clone --branch "$DAFNY_BRANCH" "$DAFNY_REPO" dafny && \
    cd dafny && \
    if [ "$DAFNY_COMMIT" != "null" ]; then git checkout "$DAFNY_COMMIT"; fi && \
    git submodule update --init --recursive && \
    cd boogie && \
    git fetch origin "$BOOGIE_BRANCH" && \
    git checkout "$BOOGIE_BRANCH" && \
    if [ "$BOOGIE_COMMIT" != "null" ]; then git checkout "$BOOGIE_COMMIT"; fi

COPY for-dockerfile/aipmda-work.bundle /app/

RUN AIPMDA_BRANCH=$(jq -r '.aipmda.branch' repos.lock.json) && \
    AIPMDA_COMMIT=$(jq -r '.aipmda.commit' repos.lock.json) && \
    git clone --branch "$AIPMDA_BRANCH" /app/aipmda-work.bundle workdir && \
    cd workdir && \
    if [ "$AIPMDA_COMMIT" != "null" ]; then git checkout "$AIPMDA_COMMIT"; fi

COPY for-dockerfile/README.md /app/

COPY for-dockerfile/dafny-ipm.yaml /app/workdir/

RUN cd /app/workdir && \
    rm -rf database tests dafny-ipm-code-ITP-submission && \
    rm -f from-mercas.zip && \
    cd test_examples && \
    find . -maxdepth 1 -type f \
      ! -name 'adt0[0-1].dfy' \
      ! -name 'adta0[0-2].dfy' \
      ! -name 'simplefun00.dfy' \
      ! -name 'funcall0[0-7].dfy' \
      ! -name 'funrec0[0-5].dfy' \
      ! -name 'simplefunfuel00.dfy' \
      ! -name 'simplefunfuelmany00.dfy' \
      ! -name 'seq00.dfy' \
      ! -name 'sets0[0-9].dfy' \
      ! -name 'iset_*.dfy' \
      ! -name 'multiset_*.dfy' \
      ! -name 'map_*.dfy' \
      ! -name 'array00.dfy' \
      ! -name 'ite_ex[2-3].dfy' \
      ! -name 'shadow0[1-3].dfy' \
      ! -name 'example_protect.dfy' \
      -delete && \
    cd examples && \
    find . -maxdepth 1 -type f \
      ! -name 'example[1-2].dfy' \
      -delete

RUN cd dafny && \
    dotnet build ./Source/Dafny.sln -c Release

RUN cd dafny/boogie && \
    dotnet build ./Source/Boogie.sln -c Release

RUN ln -s /app/dafny/Binaries/net8.0/Dafny /usr/local/bin/dafny && \
    ln -s /app/dafny/boogie/Source/BoogieDriver/bin/Release/net8.0/BoogieDriver /usr/local/bin/boogie
