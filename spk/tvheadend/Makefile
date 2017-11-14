SPK_NAME = tvheadend
SPK_VERS = 4.2.4
SPK_REV = 12
SPK_ICON = src/tvheadend.png
DSM_UI_DIR = app
BETA = 1

# DEPENDS = cross/busybox cross/$(SPK_NAME)
DEPENDS = cross/$(SPK_NAME)

MAINTAINER = m4tt075
DESCRIPTION = Tvheadend is a TV streaming server and recorder for Linux, FreeBSD and Android supporting DVB-S, DVB-S2, DVB-C, DVB-T, ATSC, ISDB-T, IPTV, SAT IP and HDHomeRun as input sources. Tvheadend offers HTTP, HTSP and SAT IP streaming.
RELOAD_UI = yes
# ADMIN_PORT = 9981
# ADMIN_PORT2 = 9982
ADMIN_PORT_TITLE = Tvheadend(HTTP)
DISPLAY_NAME = Tvheadend
CHANGELOG = "Update for full DSM6 compliance"

HOMEPAGE = https://www.lonelycoder.com/tvheadend/
LICENSE  = GPL v3

WIZARDS_DIR      = src/wizard/

# 'auto' reserved value grabs SPK_NAME
SERVICE_USER         = auto
SERVICE_WIZARD_GROUP = wizard_group
SERVICE_WIZARD_SHARE = wizard_download_dir
SERVICE_SETUP        = src/service-setup.sh
# Using standard ports 9981 for http and 9982 for htsp. Adapt SERVIC_COMMAND below if needed
SERVICE_COMMAND      = '$$\{SYNOPKG_PKGDEST\}/bin/tvheadend.sh 9981 9982 $$\{PID_FILE\}'

# INSTALLER_SCRIPT = src/installer.sh
# SSS_SCRIPT       = src/dsm-control.sh
FWPORTS          = src/${SPK_NAME}.sc
# CONF_DIR         = src/conf/

# INSTALL_PREFIX = /usr/local/$(SPK_NAME)

PRE_COPY_TARGET = tvheadend_install

# BUSYBOX_CONFIG = usrmng
# ENV += BUSYBOX_CONFIG="$(BUSYBOX_CONFIG)"

include ../../mk/spksrc.spk.mk

.PHONY: tvheadend_install
# Replace standard copy/install targets
tvheadend_install:
	rm -fr $(STAGING_DIR)
	mkdir $(STAGING_DIR)
	mkdir --parents $(STAGING_INSTALL_PREFIX)
	install -m 755 -d $(STAGING_INSTALL_PREFIX)/bin
	install -m 755 src/tvheadend.sh $(STAGING_INSTALL_PREFIX)/bin
	install -m 755 -d $(STAGING_DIR)/app
	install -m 644 src/app/config $(STAGING_DIR)/app/config
	install -m 755 -d $(STAGING_DIR)/var
	install -m 755 -d $(STAGING_DIR)/var/accesscontrol
	install -m 755 -d $(STAGING_DIR)/var/passwd
	# The following filenames stem from an arbitrary (valid) combination created by TVH
	install -m 644 src/accesscontrol.json $(STAGING_DIR)/var/accesscontrol/d80ccc09630261ffdcae1497a690acc8
	install -m 644 src/passwd.json $(STAGING_DIR)/var/passwd/a927e30a755504f9784f23a4efac5109
