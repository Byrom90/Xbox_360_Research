..\bin\xenon-as.exe CBB_13182_xebuild_patchset.s -o CBB_13182_xebuild_patchset.elf --defsym ALLTHENOPS=1
..\bin\xenon-objcopy.exe CBB_13182_xebuild_patchset.elf -O binary CBB_13182_xebuild_patchset-4G.bin
del CBB_13182_xebuild_patchset.elf