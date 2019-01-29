SUMMARY = "Shell library to parse INI files directly"
AUTHOR = "Pavel Raiskup"
HOMEPAGE = "https://github.com/praiskup/shini"
SECTION = "console/utils"
LICENSE = "LGPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=5f30f0716dfdd0d91eb439ebec522ec2"
SRCREV = "8dbbce8b6479bada93889e72ea495f4c2ec4d30a"
PV = "1.0.0+git${SRCPV}"

SRC_URI = "git://github.com/praiskup/${BPN}.git;protocol=https"

S = "${WORKDIR}/git"

inherit allarch

# Skip the unwanted steps
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_install () {
    install -Dm0755 ${S}/${BPN}.sh ${D}${libdir}/${BPN}/${BPN}.sh
}

FILES_${PN} = "${libdir}/${BPN}"
