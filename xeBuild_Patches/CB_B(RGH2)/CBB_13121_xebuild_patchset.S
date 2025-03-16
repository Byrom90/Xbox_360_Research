# This is a complete decompile of the CBB_13121 bootloader patches applied by xeBuild when building a nand for RGH systems
# They will compile 1:1 identical to the patches found in the CB section of the .bin files provided with xeBuild (& JRunner)
# Labels/Info based on https://xenonlibrary.com/wiki/Post_Codes & RGLoader patches
# - Byrom -

.include "../macros.S"

#==================================================================================
	.globl _start
_start:
#==================================================================================

#==================================================================================
#   Disables Fuse Check according to RGLoader patches 
#   Appears to bypass Panics such as:
#   Panic 0x9E - Verify Console Type - VERIFY_SECOTP_4
#   Panic 0x9F - Verify Console Type - VERIFY_SECOTP_5
#==================================================================================
# 00 00 50 48 00 00 00 01 48 00 01 68 

	MAKEPATCH 0x5048 
0:
		b 0x168     # Branch to 0x51B0
9:

#==================================================================================
#   Disables SMC Hash Check according to RGLoader patches 
#   Disables branch leading to a bunch of Panics depending on checks.
#   Effectively bypasses at least the following:
#   Panic 0xA2 - Verify Secure ROM 8 - VERIFY_SECOTP_8
#   Panic 0xA3 - Verify Secure ROM 9 - VERIFY_SECOTP_9
#   Panic 0xA4 - Verify SMC HMAC - VERIFY_SECOTP_10 - Bad SMC HMAC 
#   bne cr6, loc_5250 -> nop
#==================================================================================
# 00 00 52 40 00 00 00 01 60 00 00 00 

	MAKEPATCH 0x5240 
0:
		nop
9:

#==================================================================================
#   Disables Panic 0xAB - Verify 4BL Header - VERIFY_HEADER_4BL - Bad 4BL header
#   bl panic -> nop
#==================================================================================
# 00 00 58 AC 00 00 00 01 60 00 00 00 

	MAKEPATCH 0x58AC 
0:
		nop
9:

#==================================================================================
#   Disables Panic 0xAD - 4BL Signature Verify - SHA_VERIFY_4BL - Disable CD hash check
#   bl panic -> nop
#==================================================================================
# 00 00 59 B8 00 00 00 01 60 00 00 00

	MAKEPATCH 0x59B8 
0:
		nop
9:

#==================================================================================
	.long 0xffffffff
	.end
#==================================================================================