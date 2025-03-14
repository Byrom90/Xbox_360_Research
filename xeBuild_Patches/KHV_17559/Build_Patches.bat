..\bin\xenon-as.exe 17559_KHV_Patchset.s -o 17559_KHV_Patchset.elf
..\bin\xenon-objcopy.exe 17559_KHV_Patchset.elf -O binary 17559_KHV_Xebuild_Patches.bin
del 17559_KHV_Patchset.elf