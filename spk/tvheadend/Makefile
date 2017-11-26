SPK_NAME = tvheadend
SPK_VERS = 4.2.4
SPK_REV = 12
SPK_ICON = src/tvheadend.png
DSM_UI_DIR = app
BETA = 1

DEPENDS = cross/$(SPK_NAME)

MAINTAINER = m4tt075
DESCRIPTION = Tvheadend is a TV streaming server and recorder for Linux, FreeBSD and Android supporting DVB-S, DVB-S2, DVB-C, DVB-T, ATSC, ISDB-T, IPTV, SAT IP and HDHomeRun as input sources. Tvheadend offers HTTP, HTSP and SAT IP streaming.
RELOAD_UI = yes
DISPLAY_NAME = Tvheadend
CHANGELOG = "Update for full DSM6 compliance"
HOMEPAGE = https://www.lonelycoder.com/tvheadend/
LICENSE = GPL v3

WIZARDS_DIR = src/wizard/
CONF_DIR = src/conf/
FWPORTS = $(CONF_DIR)${SPK_NAME}.sc

# Package-specific port definitions
HTTP_PORT = 9981
HTSP_PORT = 9982

# 'auto' reserved value grabs SPK_NAME
SERVICE_USER = auto
SERVICE_WIZARD_GROUP = wizard_group
SERVICE_WIZARD_SHARE = wizard_download_dir
SERVICE_SETUP = src/service-setup.sh
SERVICE_COMMAND = '$$\{SYNOPKG_PKGDEST\}/bin/tvheadend -f -u $$\{USER\} --http_port $$\{HTTP_PORT\} --htsp_port $$\{HTSP_PORT\} -c $$\{SYNOPKG_PKGDEST\}/var'
# = '$$\{SYNOPKG_PKGDEST\}/bin/tvheadend $$\{HTTP_PORT\} $$\{HTSP_PORT\} $$\{PID_FILE\}'


PRE_COPY_TARGET = tvheadend_install
POST_STRIP_TARGET = tvheadend_extra_install

include ../../mk/spksrc.spk.mk

.PHONY: tvheadend_install
# Replace standard copy/install targets
tvheadend_install:
	rm -fr $(STAGING_DIR)
	mkdir $(STAGING_DIR)
	mkdir --parents $(STAGING_INSTALL_PREFIX)
	install -m 755 -d $(STAGING_INSTALL_PREFIX)/bin
	install -m 755 src/tvheadend.sh $(STAGING_INSTALL_PREFIX)/bin/tvheadend.sh

.PHONY: tvheadend_extra_install
tvheadend_extra_install:
	install -m 755 -d $(STAGING_DIR)/app
	install -m 644 src/app/config $(STAGING_DIR)/app/config
	install -m 755 -d $(STAGING_DIR)/var
	install -m 755 -d $(STAGING_DIR)/var/accesscontrol
	install -m 755 -d $(STAGING_DIR)/var/passwd
	# The following filenames stem from an arbitrary (valid) combination created by TVH
	install -m 644 src/accesscontrol.json $(STAGING_DIR)/var/accesscontrol/d80ccc09630261ffdcae1497a690acc8
	install -m 644 src/passwd.json $(STAGING_DIR)/var/passwd/a927e30a755504f9784f23a4efac5109
