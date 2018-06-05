FROM maidbot/resin-raspberrypi3-qemu

MAINTAINER Breandan Considine breandan.considine@nutonomy.com

RUN [ "cross-build-start" ]

# Switch on systemd init system in container and set various other variables
ENV INITSYSTEM="on" \
    TERM="xterm" \
    ROS_DISTRO="kinetic"

RUN echo "deb http://packages.ros.org/ros/ubuntu trusty main" > /etc/apt/sources.list.d/ros-latest.list \
    && apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net --recv-key 0xB01FA116

RUN apt-get clean && apt-get update && apt-get upgrade -y

# System dependencies
RUN apt-get install -yq --no-install-recommends --fix-missing \
    sudo locales locales-all \
    etckeeper emacs vim byobu zsh git git-extras htop atop nethogs iftop apt-file ntpdate \
    build-essential libblas-dev liblapack-dev libatlas-base-dev gfortran libyaml-cpp-dev

# Python Dependencies
RUN apt-get install -yq --no-install-recommends --fix-missing \
    python-dev python-pip ipython python-sklearn python-smbus python-termcolor python-frozendict \
    python-tables i2c-tools libxslt-dev libxml2-dev python-lxml python-bs4 python-enum python-rpi.gpio    

# ROS dependencies
RUN apt-get install -yq --no-install-recommends --fix-missing \
      python-rosdep python-catkin-tools ros-kinetic-navigation ros-kinetic-robot-localization \
      ros-kinetic-roslint ros-kinetic-hector-trajectory-server \
      ros-kinetic-ros-tutorials ros-kinetic-common-tutorials ros-kinetic-robot 
    
RUN ln -s /usr/lib/arm-linux-gnueabihf/liblog4cxx.so /usr/lib/

RUN pip install platformio

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt-get clean && rm -rf /var/lib/apt/lists

RUN pip install --upgrade --user \
        PyContracts==1.7.15 \
        DecentLogs==1.1.2\
        QuickApp==1.3.8 \
        conftools==1.9.1 \
        comptests==1.4.10 \
        procgraph==1.10.6 \
        pymongo==3.5.1 \
        ruamel.yaml==0.15.34
        
RUN rosdep init && rosdep update

RUN git clone https://github.com/duckietown/software /home/

COPY ./ros_entrypoint.sh .

RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash && catkin_make -C /home/software/catkin_ws/"

RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc

RUN [ "cross-build-end" ]

ENTRYPOINT ["bash", "ros_entrypoint.sh"]

CMD ["bash"]
