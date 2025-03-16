# This is a complete decompile of the CBB_5772 bootloader patches applied by xeBuild when building a nand for RGH systems
# They will compile 1:1 identical to the patches found in the CB section of the .bin files provided with xeBuild (& JRunner)
# Labels/Info based on https://xenonlibrary.com/wiki/Post_Codes
# - Byrom -

.include "../macros.S"

#==================================================================================
	.globl _start
_start:
#==================================================================================

#==================================================================================
#	Disables branch leading to further checks potentially resulting in:
#	Panic 0xA0 - VERIFY_SECOTP_6 - Verify 2BL Revocation - 2BL LDV mismatch 
#	bne cr6, loc_6954 -> nop
#==================================================================================
# 00 00 69 44 00 00 00 01 60 00 00 00 

	MAKEPATCH  0x6944
0:
		nop
9:

#==================================================================================
#	Disables Panic 0xA3 - Verify Secure ROM 9 - VERIFY_SECOTP_9
#	bne cr6, loc_6AC0 -> nop
#	cmplwi cr6, r30, 0x3000 -> nop
#	bne cr6, loc_6AC0 -> nop
#==================================================================================
# 00 00 6A A0 00 00 00 03 60 00 00 00 60 00 00 00 60 00 00 00 

	MAKEPATCH  0x6AA0
0:
		nop
        nop
        nop
9:

#==================================================================================
#	Disables Panic 0xAD - 4BL Signature Verify - SHA_VERIFY_4BL - Disable CD hash check
#	bl XeCryptMemDiff -> li r3, 0
#==================================================================================
# 00 00 71 B0 00 00 00 01 38 60 00 00

	MAKEPATCH  0x71B0
0:
		li     %r3, 0
9:

#============================================================================
	.long 0xFFFFFFFF
	.end
#============================================================================
