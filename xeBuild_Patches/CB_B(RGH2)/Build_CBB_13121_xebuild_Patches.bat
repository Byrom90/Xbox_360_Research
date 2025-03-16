..\bin\xenon-as.exe CBB_13121_xebuild_patchset.s -o CBB_13121_xebuild_patchset.elf
..\bin\xenon-objcopy.exe CBB_13121_xebuild_patchset.elf -O binary CBB_13121_xebuild_patchset.bin
del CBB_13121_xebuild_patchset.elf