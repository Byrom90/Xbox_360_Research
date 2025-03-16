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
#	bne cr6, loc_54B4 -> nop
#==================================================================================
# 00 00 54 A4 00 00 00 01 60 00 00 00

	MAKEPATCH  0x54A4
0:
		nop
9:

#==================================================================================
#	Disables Panic 0xA3 - Verify Secure ROM 9 - VERIFY_SECOTP_9
#	bne cr6, loc_5620 -> nop
#	cmplwi cr6, r30, 0x3000 -> nop
#	bne cr6, loc_5620 -> nop
#==================================================================================
# 00 00 56 00 00 00 00 03 60 00 00 00 60 00 00 00 60 00 00 00

	MAKEPATCH  0x5600
0:
		nop
        nop
        nop
9:

#==================================================================================
#	Disables Panic 0xAD - 4BL Signature Verify - SHA_VERIFY_4BL - Disable CD hash check
#	bl XeCryptMemDiff -> li r3, 0
#==================================================================================
# 00 00 5D 98 00 00 00 01 38 60 00 00

	MAKEPATCH  0x5D98
0:
		li     %r3, 0
9:

#============================================================================
	.long 0xFFFFFFFF
	.end
#============================================================================
