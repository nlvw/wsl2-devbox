FROM docker.io/almalinux:9

ADD build_scripts/el9/base.sh /root/base.sh
RUN /bin/bash /root/base.sh

ADD build_scripts/el9/dev.sh /root/dev.sh
RUN /bin/bash /root/dev.sh

ARG NVIDIA=false
ADD build_scripts/el9/nvidia.sh /root/nvidia.sh 
RUN /bin/bash /root/nvidia.sh ${NVIDIA}