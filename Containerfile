# Mac podman で使われる ホスト が testing のため (ベースの kernel バージョンを合わせるため)
FROM quay.io/fedora/fedora-coreos:testing

RUN rpm-ostree install --apply-live --allow-inactive unzip wget git koji

# work directory
RUN mkdir /var/temp
WORKDIR /var/temp

# install kernel-devel
RUN koji download-build --rpm --arch=src kernel-devel-`uname -r`
RUN rpm-ostree install --apply-live --allow-inactive kernel-devel-`uname -r`.rpm

# 上記のパッケージに使われている binutils で、/var/lib/alternatives を使うが CoreOS では扱えないための回避策
RUN ln -s /usr/bin/ld.bfd /usr/bin/ld

RUN git clone https://github.com/nns779/px4_drv

# extract firmware
WORKDIR /var/temp/px4_drv/fwtool
RUN make
RUN wget http://plex-net.co.jp/plex/pxw3u4/pxw3u4_BDA_ver1x64.zip -O pxw3u4_BDA_ver1x64.zip
RUN unzip -oj pxw3u4_BDA_ver1x64.zip pxw3u4_BDA_ver1x64/PXW3U4.sys
RUN ./fwtool PXW3U4.sys it930x-firmware.bin
RUN mkdir -p /lib/firmware
RUN cp it930x-firmware.bin /lib/firmware/

# create kernel driver
WORKDIR /var/temp/px4_drv/driver
RUN sed -i 's/class_create(THIS_MODULE, name)/class_create(name)/' ./ptx_chrdev.c
RUN make
# modprobe は動かないので。
#RUN make install
RUN install -D -v -m 644 px4_drv.ko /lib/modules/`uname -r`/misc/px4_drv.ko
RUN install -D -v -m 644 ../etc/99-px4video.rules /etc/udev/rules.d/99-px4video.rules
RUN depmod -a `uname -r`

WORKDIR /
RUN rm -rf /var/temp
RUN ostree container commit

CMD setsebool -P container_use_devices=true