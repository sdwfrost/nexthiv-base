FROM jupyter/minimal-notebook:latest

LABEL maintainer="Simon Frost <sdwfrost@gmail.com>"

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -yq dist-upgrade\
    && apt-get install -yq \
    autoconf \
    automake \
    ant \
    apt-file \
    apt-utils \
    apt-transport-https \
    asymptote \
    build-essential \
    bzip2 \
    ca-certificates \
    cmake \
    curl \
    darcs \
    debhelper \
    devscripts \
    dirmngr \
    ed \
    ffmpeg \
    fonts-liberation \
    fonts-dejavu \
    gcc \
    gcc-multilib \
    g++ \
    g++-multilib \
    gdebi-core \
    gfortran \
    gfortran-multilib \
    ghostscript \
    ginac-tools \
    git \
    gnuplot \
    gnupg \
    gnupg-agent \
    graphviz \
    graphviz-dev \
    groovy \
    gzip \
    haskell-stack \
    lib32z1-dev \
    libatlas-base-dev \
    libc6-dev \
    libffi-dev \
    libgdal-dev \
    libgmp-dev \
    libgsl0-dev \
    libtinfo-dev \
    libzmq3-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libmagic-dev \
    libblas-dev \
    liblapack-dev \
    libboost-all-dev \
    libcln-dev \
    libcurl4-gnutls-dev \
    libgeos-dev \
    libgeos-c1v5 \
    libginac-dev \
    libginac6 \
    libgit2-dev \
    libgl1-mesa-dev \
    libgl1-mesa-glx \
    libglfw3 \
    libglfw3-dev \
    libgraphviz-dev \
    libgs-dev \
    libjsoncpp-dev \
    libmagick++-dev \
    libnetcdf-dev \
    libopenblas-dev \
    libproj-dev \
    libqrupdate-dev \
    libqt5widgets5 \
    libsm6 \
    libssl-dev \
    libudunits2-0 \
    libudunits2-dev \
    libunwind-dev \
    libxext-dev \
    libxml2-dev \
    libxrender1 \
    libxt6 \
    libzmqpp-dev \
    libv8-dev \
    llvm-6.0-dev \
    libclang-6.0-dev \
    lmodern \
    locales \
    m4 \
    mercurial \
    musl-dev \
    netcat \
    ocaml \
    octave \
    octave-dataframe \
    octave-general \
    octave-gsl \
    octave-nlopt \
    octave-odepkg \
    octave-optim \
    octave-symbolic \
    octave-miscellaneous \
    octave-missing-functions \
    octave-pkg-dev \
    opam \
    openjdk-8-jdk \
    openjdk-8-jre \
    pandoc \
    pari-gp \
    pari-gp2c \
    pbuilder \
    pkg-config \
    psmisc \
    python3-dev \
    rsync \
    sbcl \
    software-properties-common \
    sqlite \
    sqlite3 \
    sudo \
    swig \
    tzdata \
    ubuntu-dev-tools \
    unzip \
    uuid-dev \
    xorg-dev \
    wget \
    xz-utils \
    zlib1g-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN update-java-alternatives --set /usr/lib/jvm/java-1.8.0-openjdk-amd64

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -yq --no-install-recommends \
    nodejs \
    nodejs-legacy \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Configure environment
ENV SHELL=/bin/bash \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV HOME=/home/$NB_USER

# Python libraries

RUN conda install ipython

RUN pip install \
    cython \
    gr \
    ipykernel \
    ipywidgets \
    joblib \
    jupyter \
    jupyter-client \
    jupyter-core \
    jupyter_nbextensions_configurator \
    jupyter_contrib_nbextensions \
    jupyter-console \
    matplotlib \
    networkx \
    nteract_on_jupyter \
    nxpd \
    numba \
    numexpr \
    pandas \
    papermill \
    plotly \
    ply \
    pydot \
    pygraphviz \
    pythran \
    scipy \
    seaborn \
    setuptools \
    sympy \
    tqdm \
    tzlocal \
    ujson && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions /home/$NB_USER

# R
RUN add-apt-repository ppa:marutter/rrutter3.5 && \
    apt-get update && \
    apt-get install -yq \
    r-base r-base-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/share/jupyter/kernels
RUN R -e "setRepositories(ind=1:2);install.packages(c(\
    'devtools'), dependencies=TRUE, clean=TRUE, repos='https://cran.microsoft.com/snapshot/2018-11-01')"
RUN R -e "devtools::install_github('IRkernel/IRkernel')" && \
    R -e "IRkernel::installspec()" && \
    mv $HOME/.local/share/jupyter/kernels/ir* /usr/local/share/jupyter/kernels/ && \
    chmod -R go+rx /usr/local/share/jupyter && \
    fix-permissions /usr/local/share/jupyter /usr/local/lib/R
RUN pip install rpy2


# Graphviz
RUN cd /tmp && \
    git clone https://github.com/laixintao/jupyter-dot-kernel.git && \
    cd jupyter-dot-kernel && \
    jupyter kernelspec install dot_kernel_spec && \
    cd /tmp && \
    rm -rf jupyter-dot-kernel


# Asymptote magic
RUN mkdir -p ${HOME}/.ipython/extensions && \
    cd ${HOME}/.ipython/extensions && \
    wget https://raw.githubusercontent.com/jrjohansson/ipython-asymptote/master/asymptote.py


# MKL
RUN cd /tmp && \
    wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
    apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
    sh -c 'echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list' && \
    apt-get update && \
    apt-get install -yq intel-mkl-64bit-2018.2-046 && \
    update-alternatives --install /usr/lib/x86_64-linux-gnu/libblas.so     libblas.so-x86_64-linux-gnu      /opt/intel/mkl/lib/intel64/libmkl_rt.so 50 && \
    update-alternatives --install /usr/lib/x86_64-linux-gnu/libblas.so.3   libblas.so.3-x86_64-linux-gnu    /opt/intel/mkl/lib/intel64/libmkl_rt.so 50 && \
    update-alternatives --install /usr/lib/x86_64-linux-gnu/liblapack.so   liblapack.so-x86_64-linux-gnu    /opt/intel/mkl/lib/intel64/libmkl_rt.so 50 && \
    update-alternatives --install /usr/lib/x86_64-linux-gnu/liblapack.so.3 liblapack.so.3-x86_64-linux-gnu  /opt/intel/mkl/lib/intel64/libmkl_rt.so 50 && \
    echo "/opt/intel/lib/intel64"     >  /etc/ld.so.conf.d/mkl.conf && \
    echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/mkl.conf && \
    ldconfig && \
    echo "MKL_THREADING_LAYER=GNU" >> /etc/environment && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Rust and Rust
RUN mkdir /opt/cargo && \
    mkdir /opt/rustup
ENV CARGO_HOME=/opt/cargo \
    RUSTUP_PATH=/opt/rustup
ENV PATH=/opt/cargo/bin:$PATH
RUN cd /tmp && \
    curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    cargo install cargo-script && \
    echo '// cargo-deps: eom="0.10.0", ndarray="0.11"\nfn main(){}' > hello.rs && \
    cargo script hello.rs && \
    rm hell*
RUN cargo install evcxr_jupyter && \
    evcxr_jupyter --install && \
    mv ${HOME}/.local/share/jupyter/kernels/rust /usr/local/share/jupyter/kernels/rust && \
    fix-permissions /usr/local/share/jupyter/kernels ${HOME}

# Node
RUN mkdir /opt/npm && \
    echo 'prefix=/opt/npm' >> ${HOME}/.npmrc 
ENV PATH=/opt/npm/bin:$PATH
ENV NODE_PATH=/opt/npm/lib/node_modules
RUN fix-permissions /opt/npm

# Go
RUN cd /tmp && \
    wget https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz && \
    mkdir /opt/go && \
    tar xvf go1.11.2.linux-amd64.tar.gz -C /opt/go --strip-components=1 && \
    rm go1.11.2.linux-amd64.tar.gz && \
    fix-permissions /opt/go
ENV GOPATH=${HOME}/.local/go
ENV PATH=/opt/go/bin:${HOME}/.local/go/bin:$PATH
RUN go get -u github.com/gopherdata/gophernotes && \
    mkdir -p /usr/local/share/jupyter/kernels/gophernotes && \
    cp $GOPATH/src/github.com/gopherdata/gophernotes/kernel/* /usr/local/share/jupyter/kernels/gophernotes
RUN fix-permissions $GOPATH /usr/local/share/jupyter/kernels


# Stan
RUN cd /opt && \
    git clone https://github.com/stan-dev/cmdstan.git --recursive && \
    cd cmdstan && \
    make build
ENV PATH=/opt/cmdstan/bin:$PATH

USER ${NB_USER}

RUN npm install -g ijavascript \
    plotly-notebook-js && \
    ijsinstall

USER root
RUN mv ${HOME}/.local/share/jupyter/kernels/javascript /usr/local/share/jupyter/kernels/javascript

# Tidy up permissions and ownership
RUN fix-permissions /tmp /opt ${HOME} /usr/local/share/jupyter/kernels /usr/local/lib/python3.6 && \
    chown -R ${NB_USER}:users /opt && \
    chown -R ${NB_USER}:users /tmp && \
    chown -R ${NB_USER}:users ${HOME}

USER ${NB_USER}
RUN cd ${HOME}
