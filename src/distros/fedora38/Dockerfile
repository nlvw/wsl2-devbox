FROM registry.fedoraproject.org/fedora:38

ADD build_scripts/fedora/base.sh /root/base.sh
RUN /bin/bash /root/base.sh

ADD build_scripts/fedora/dev.sh /root/dev.sh
RUN /bin/bash /root/dev.sh

ARG NVIDIA=false
ADD distros/fedora38/nvidia.sh /root/nvidia.sh 
RUN /bin/bash /root/nvidia.sh ${NVIDIA}