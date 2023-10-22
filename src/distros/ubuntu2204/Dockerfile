FROM local-url-rootfs

ADD build_scripts/ubuntu/base.sh /root/base.sh
RUN /bin/bash /root/base.sh

ADD build_scripts/ubuntu/dev.sh /root/dev.sh
RUN /bin/bash /root/dev.sh

#ARG NVIDIA=false
#ADD distros/ubuntu2204/nvidia.sh /root/nvidia.sh 
#RUN /bin/bash /root/nvidia.sh ${NVIDIA}
