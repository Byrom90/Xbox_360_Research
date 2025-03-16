..\bin\xenon-as.exe CBB_5772_xebuild_patchset.s -o CBB_5772_xebuild_patchset.elf
..\bin\xenon-objcopy.exe CBB_5772_xebuild_patchset.elf -O binary CBB_5772_xebuild_patchset.bin
del CBB_5772_xebuild_patchset.elf