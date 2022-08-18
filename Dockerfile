FROM fuzzers/afl:2.52

RUN apt-get update
RUN apt install -y build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev libjpeg-dev
RUN wget https://www.ijg.org/files/jpegsrc.v9e.tar.gz
RUN tar xvfz jpegsrc.v9e.tar.gz
WORKDIR /jpeg-9e
RUN ./configure CC=afl-clang CXX=afl-clang++
RUN make
RUN make install
WORKDIR /
RUN git clone https://github.com/jsummers/imageworsener.git
WORKDIR /imageworsener
RUN ./scripts/autogen.sh
RUN ./configure CC=afl-clang CXX=afl-clang++
RUN make
RUN make install
RUN mkdir /imageWorseCorpus
RUN wget https://download.samplelib.com/jpeg/sample-clouds-400x300.jpg
RUN wget https://download.samplelib.com/jpeg/sample-red-400x300.jpg
RUN wget https://download.samplelib.com/jpeg/sample-green-200x200.jpg
RUN wget https://download.samplelib.com/jpeg/sample-green-100x75.jpg
RUN mv *.jpg /imageWorseCorpus
ENV LD_LIBRARY_PATH=/usr/local/lib

ENTRYPOINT ["afl-fuzz", "-i", "/imageWorseCorpus", "-o", "/imageWorseOut"]
CMD ["/usr/local/lib/imagew", "@@", "out.png"]
