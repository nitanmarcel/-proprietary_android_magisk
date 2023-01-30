#!/bin/bash

ARCH=$1
TRANSLATION_TOOL=$2
WORKDIR=$(pwd)

64_prop() {
    cat << EOF > magisk-module/system.prop
ro.product.cpu.abilist=x86_64,x86,arm64-v8a,armeabi-v7a,armeabi
ro.product.cpu.abilist32=x86,armeabi-v7a,armeabi
ro.product.cpu.abilist64=x86_64,arm64-v8a
ro.vendor.product.cpu.abilist=x86_64,x86,arm64-v8a,armeabi-v7a,armeabi
ro.vendor.product.cpu.abilist32=x86,armeabi-v7a,armeabi
ro.vendor.product.cpu.abilist64=x86_64,arm64-v8a
ro.odm.product.cpu.abilist=x86_64,x86,arm64-v8a,armeabi-v7a,armeabi
ro.odm.product.cpu.abilist32=x86,armeabi-v7a,armeabi
ro.odm.product.cpu.abilist64=x86_64,arm64-v8a
ro.dalvik.vm.native.bridge=$1
ro.enable.native.bridge.exec=1
ro.enable.native.bridge.exec64=1
ro.dalvik.vm.isa.arm=x86
ro.dalvik.vm.isa.arm64=x86_64
EOF
}

32_prop() {
    cat << EOF > magisk-module/system.prop
ro.product.cpu.abilist=x86,armeabi-v7a,armeabi
ro.product.cpu.abilist32=x86,armeabi-v7a,armeabi
ro.vendor.product.cpu.abilist=x86,armeabi-v7a,armeabi
ro.vendor.product.cpu.abilist32=x86,armeabi-v7a,armeabi
ro.vendor.product.cpu.abilist64=
ro.odm.product.cpu.abilist=x86,armeabi-v7a,armeabi
ro.odm.product.cpu.abilist32=x86,armeabi-v7a,armeabi
ro.dalvik.vm.native.bridge=$1
ro.enable.native.bridge.exec=1
ro.enable.native.bridge.exec64=
ro.dalvik.vm.isa.arm=x86
EOF
}

if [ "${ARCH}" == "x86" ]; then
    if [ "${TRANSLATION_TOOL}" == "libhoudini" ]; then
        echo "libhoudini is not available on x86"
        exit 1;
    fi
fi

if [ "${TRANSLATION_TOOL}" == "libndk" ]; then
    chmod +x ./Droid-NDK-Extractor/android-extract-ndk.sh
    ./Droid-NDK-Extractor/android-extract-ndk.sh "${ARCH}"
    rm -rf magisk-module/system 2> /dev/null
    tar -xvf working/extracted/native-bridge.tar -C magisk-module/
fi

if [ "${TRANSLATION_TOOL}" == "libhoudini" ]; then
    rm -rf magisk-module/system 2> /dev/null
    cp -r libhoudini-package/system magisk-module/    
    64_prop "libhoudini.so"
elif [ "${ARCH}" == "x86_64" ]; then
    if [ "${TRANSLATION_TOOL}" == "libndk" ]; then
        64_prop "libndk_translation.so"
    fi
elif [ "${ARCH}" == "x86" ]; then
    32_prop "libndk_translation.so"
fi

cd magisk-module
echo $(pwd)
zip -r "${WORKDIR}/proprietary_android_magisk-${ARCH}_${TRANSLATION_TOOL}.zip" .
cd "${WORKDIR}"
