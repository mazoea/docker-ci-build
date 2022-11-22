FROM lambci/lambda:build-python3.8 

RUN yum update && yum -y install gdb

RUN gdb --version

CMD ["gdb"]