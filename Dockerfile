FROM lambci/lambda:build-python3.8 

RUN yum update -y && yum install -y gdb

RUN gdb --version

CMD ["gdb"]