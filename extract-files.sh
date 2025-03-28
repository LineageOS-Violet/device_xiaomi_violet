# Default to sanitizing the vendor folder before extraction
#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.file import File
from extract_utils.fixups_blob import (
    BlobFixupCtx,
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixup_remove,
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

# Define namespace imports relevant to the device
namespace_imports = [
    'device/xiaomi/violet',
    'hardware/qcom-caf/sm6150',
    'hardware/qcom-caf/wlan',
    'hardware/xiaomi',
    'vendor/qcom/opensource/commonsys/display',
    'vendor/qcom/opensource/commonsys-intf/display',
    'vendor/qcom/opensource/dataservices',
    'vendor/qcom/opensource/display',
]

# Define library fix-ups specific to the device
def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'vendor' else None

lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    (
        'com.qualcomm.qti.dpm.api@1.0',
        'libmmosal',
        'vendor.qti.hardware.fm@1.0',
        'vendor.qti.imsrtpservice@3.0',
        'vendor.qti.hardware.wifidisplaysession@1.0',
    ): lib_fixup_vendor_suffix,
    (
        'libwpa_client',
    ): lib_fixup_remove,
}

# Define blob fix-ups specific to the device
blob_fixups: blob_fixups_user_type = {
    'vendor/lib/libwvhidl.so': blob_fixup()
        .replace_needed('libcrypto.so', 'libcrypto-v34.so'),
    'vendor/lib/mediadrm/libwvdrmengine.so': blob_fixup()
        .replace_needed('libcrypto.so', 'libcrypto-v34.so'),
    'vendor/lib64/libwvhidl.so': blob_fixup()
        .replace_needed('libcrypto.so', 'libcrypto-v34.so'),
    'vendor/lib64/mediadrm/libwvdrmengine.so': blob_fixup()
        .replace_needed('libcrypto.so', 'libcrypto-v34.so'),
    'vendor/lib64/libvidhance.so': blob_fixup()
        .add_needed('libc++demangle.so')
        .add_needed('libcomparetf2.so'),
    'vendor/lib64/camera/components/com.vidhance.node.eis.so': blob_fixup()
        .add_needed('libc++demangle.so')
        .add_needed('libcomparetf2.so'),
    'vendor/lib64/camera/components/com.vidhance.stats.aec_dmbr.so': blob_fixup()
        .add_needed('libcomparetf2.so'),
    'vendor/lib64/hw/camera.qcom.so': blob_fixup()
        .regex_replace(r'libc\+\+\.so', 'libc29.so'),
    'vendor/bin/mlipayd@1.1': blob_fixup()
        .remove_needed('vendor.xiaomi.hardware.mtdservice@1.0.so'),
    'vendor/lib64/libmlipay.so': blob_fixup()
        .remove_needed('vendor.xiaomi.hardware.mtdservice@1.0.so'),
    'vendor/lib64/libmlipay@1.1.so': blob_fixup()
        .remove_needed('vendor.xiaomi.hardware.mtdservice@1.0.so'),
    'system_ext/lib64/libwfdnative.so': blob_fixup()
        .remove_needed('android.hidl.base@1.0.so'),
    'system_ext/lib/libwfdnative.so': blob_fixup()
        .remove_needed('android.hidl.base@1.0.so'),
    'vendor/lib64/libgoodixhwfingerprint.so': blob_fixup()
        .remove_needed('android.hidl.base@1.0.so'),
    'vendor/etc/camera/camxoverridesettings.txt': blob_fixup()
        .regex_replace(r'0x10080', '0')
        .regex_replace(r'0x1F', '0x0'),
    'vendor/lib64/libvendor.goodix.hardware.interfaces.biometrics.fingerprint@2.1.so': blob_fixup()
        .remove_needed('libhidlbase.so')
        .regex_replace(r'libhidltransport.so', 'libhidlbase-v32.so\x00'),
    'vendor/lib64/mediadrm/libwvdrmengine.so': blob_fixup()
        .replace_needed('libprotobuf-cpp-lite-3.9.1.so', 'libprotobuf-cpp-full-3.9.1.so'),
    'vendor/lib/mediadrm/libwvdrmengine.so': blob_fixup()
        .replace_needed('libprotobuf-cpp-lite-3.9.1.so', 'libprotobuf-cpp-full-3.9.1.so'),
    'vendor/lib64/libwvhidl.so': blob_fixup()
        .replace_needed('libprotobuf-cpp-lite-3.9.1.so', 'libprotobuf-cpp-full-3.9.1.so'),
}

# Initialize the extraction module with device-specific configurations
module = ExtractUtilsModule(
    device='violet',
    vendor='xiaomi',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
