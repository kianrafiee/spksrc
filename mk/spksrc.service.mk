### Service rules
# Generate background service support files in SPK:
#   scripts/installer
#   scripts/start-stop-status
#   scripts/service-setup
#   conf/privilege            if SERVICE_USER
#   conf/resource/SPK_NAME.sc if ADMIN_PORT
#   app/config                if DSM_UI_DIR
#
# Target are executed in the following order:
#  service_msg_target
#  pre_service_target   (override with PRE_SERVICE_TARGET)
#  service_target       (override with SERVICE_TARGET)
#  post_service_target  (override with POST_SERVICE_TARGET)

ifeq ($(strip $(PRE_SERVICE_TARGET)),)
PRE_SERVICE_TARGET = pre_service_target
else
$(PRE_SERVICE_TARGET): service_msg_target
endif
ifeq ($(strip $(SERVICE_TARGET)),)
SERVICE_TARGET = service_target
else
$(SERVICE_TARGET): $(PRE_SERVICE_TARGET)
endif
ifeq ($(strip $(POST_SERVICE_TARGET)),)
POST_SERVICE_TARGET = post_service_target
else
$(POST_SERVICE_TARGET): $(SERVICE_TARGET)
endif

ifeq ($(strip $(SERVICE_USER)),)
PRE_SERVICE_TARGET = pre_service_target
else
$(PRE_SERVICE_TARGET): service_msg_target
endif

.PHONY: service_target service_msg_target $(DSM_SCRIPTS_DIR)/service-setup
.PHONY: $(PRE_SERVICE_TARGET) $(SERVICE_TARGET) $(POST_SERVICE_TARGET)

service_msg_target:
	@$(MSG) "Generating service scripts for $(NAME)"

pre_service_target: service_msg_target

# auto uses SPK_NAME
ifeq ($(SERVICE_USER),auto)
SPK_USER = $(SPK_NAME)
else
SPK_USER = $(SERVICE_USER)
endif

# Recommend explicit STARTABLE=no
ifeq ($(strip $(SSS_SCRIPT)),)
ifeq ($(strip $(SERVICE_COMMAND)),)
ifeq ($(strip $(STARTABLE)),)
$(error Set STARTABLE=no or provide either SERVICE_COMMAND or specific SSS_SCRIPT)
endif
endif
endif

SPKSRC_MK = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

SERVICE_FILES =

# Generate service-setup from SERVICE variables
$(DSM_SCRIPTS_DIR)/service-setup:
	$(create_target_dir)
	@echo "### Package specific variables and functions " >> $@
ifneq ($(strip $(SPK_USER)),)
	@echo "# Service USER to run background process" >> $@
	@echo USER=\"$(SPK_USER)\" >> $@
endif
ifneq ($(strip $(SERVICE_WIZARD_GROUP)),)
	@echo "# Group name from UI if provided" >> $@
	@echo 'if [ -n "$${$(SERVICE_WIZARD_GROUP)}" ]; then GROUP="$${$(SERVICE_WIZARD_GROUP)}"; fi' >> $@
endif
ifneq ($(strip $(SERVICE_WIZARD_SHARE)),)
	@echo "# Share download location from UI if provided" >> $@
	@echo 'if [ -n "$${$(SERVICE_WIZARD_SHARE)}" ]; then SHARE_PATH="$${$(SERVICE_WIZARD_SHARE)}"; fi' >> $@
endif
ifneq ($(strip $(ADMIN_PORT)),)
	@echo "# Service port" >> $@
	@echo 'ADMIN_PORT="$(ADMIN_PORT)"' >> $@
endif
ifneq ($(STARTABLE),no)
	@echo "# start-stop-status script redirect stdout/stderr to LOG_FILE" >> $@
	@echo 'LOG_FILE="$${SYNOPKG_PKGDEST}/var/$${SYNOPKG_PKGNAME}.log"' >> $@
	@echo "# Service command has to deliver its pid into PID_FILE" >> $@
	@echo 'PID_FILE="$${SYNOPKG_PKGDEST}/var/$${SYNOPKG_PKGNAME}.pid"' >> $@
endif
ifneq ($(strip $(SERVICE_COMMAND)),)
	@echo "# Service shell to run command" >> $@
ifneq ($(strip $(SERVICE_SHELL)),)
	@echo 'SERVICE_SHELL="$(SERVICE_SHELL)"' >> $@
else
	@echo 'SERVICE_SHELL="/bin/sh"' >> $@
endif
	@echo "# Service command to execute (either with shell or as is)" >> $@
	@echo 'SERVICE_COMMAND="$(SERVICE_COMMAND)"' >> $@
endif
	@cat $(SPKSRC_MK)spksrc.service.call_func >> $@
ifneq ($(strip $(SERVICE_SETUP)),)
	@cat $(CURDIR)/$(SERVICE_SETUP) >> $@
endif
DSM_SCRIPTS_ += service-setup
SERVICE_FILES += $(DSM_SCRIPTS_DIR)/service-setup


# Control use of generic installer
ifeq ($(strip $(INSTALLER_SCRIPT)),)
DSM_SCRIPTS_ += installer
$(DSM_SCRIPTS_DIR)/installer: $(SPKSRC_MK)spksrc.service.installer
	@$(dsm_script_copy)
endif

# Control use of generic start-stop-status scripts
ifeq ($(strip $(SSS_SCRIPT)),)
DSM_SCRIPTS_ += start-stop-status
ifeq ($(STARTABLE),no)
$(DSM_SCRIPTS_DIR)/start-stop-status: $(SPKSRC_MK)spksrc.service.non-startable
	@$(dsm_script_copy)
else
$(DSM_SCRIPTS_DIR)/start-stop-status: $(SPKSRC_MK)spksrc.service.start-stop-status
	@$(dsm_script_copy)
endif
endif


# Generate privilege file for service user
ifneq ($(strip $(SPK_USER)),)
$(DSM_CONF_DIR)/privilege: $(SPKSRC_MK)spksrc.service.privilege
	$(create_target_dir)
	@sed 's|USER|$(SPK_USER)|' $< > $@
	$(eval SPK_CONTENT += conf)

SERVICE_FILES += $(DSM_CONF_DIR)/privilege
endif


# Generate service configuration for admin port
ifneq ($(strip $(ADMIN_PORT)),)
ifeq ($(strip $(FWPORTS)),)
$(DSM_CONF_DIR)/$(SPK_NAME).sc:
	$(create_target_dir)
	@echo "[$(SPK_NAME)]" >> $@
ifneq ($(strip $(ADMIN_PORT_TITLE)),)
	@echo "title=\"$(ADMIN_PORT_TITLE)\"" >> $@
else
	@echo "title=\"$(SPK_NAME)\"" >> $@
endif
ifneq ($(strip $(DISPLAY_NAME)),)
	@echo "desc=\"$(DISPLAY_NAME)\"" >> $@
else
	@echo "desc=\"$(SPK_NAME)\"" >> $@
endif
	@echo "port_forward=\"yes\"" >> $@
	@echo "dst.ports=\"${ADMIN_PORT}/tcp\"" >> $@
	$(eval SPK_CONTENT += conf)
else
$(DSM_CONF_DIR)/$(SPK_NAME).sc: $(filter %.sc,$(FWPORTS))
	@$(dsm_script_copy)
	$(eval SPK_CONTENT += conf)
endif
SERVICE_FILES += $(DSM_CONF_DIR)/$(SPK_NAME).sc
endif


# Generate DSM UI configuration
ifneq ($(strip $(SPK_ICON)),)
ifneq ($(strip $(ADMIN_PORT)),)
# Set some defaults
ifeq ($(strip $(ADMIN_URL)),)
ADMIN_URL=/
endif
ifeq ($(strip $(ADMIN_PORT_PROTOCOL)),)
ADMIN_PORT_PROTOCOL=http
endif
ifeq ($(strip $(ADMIN_PORT_ALL_USERS)),)
ADMIN_PORT_ALL_USERS=true
endif
ifeq ($(strip $(DSM_UI_DIR)),)
DSM_UI_DIR=app
endif

$(STAGING_DIR)/$(DSM_UI_DIR)/config:
	$(create_target_dir)
	@echo '{ ".url": { ' >> $@
	@echo "  \"com.synocommunity.packages.${SPK_NAME}\": {" >> $@
	@echo "    \"title\": \"${DISPLAY_NAME}\"," >> $@
	@echo "    \"desc\": \"${DESCRIPTION}\"," >> $@
	@echo "    \"icon\": \"images/${SPK_NAME}-{0}.png\"," >> $@
	@echo "    \"type\": \"url\"," >> $@
	@echo "    \"protocol\": \"${ADMIN_PORT_PROTOCOL}\"," >> $@
	@echo "    \"port\": \"${ADMIN_PORT}\"," >> $@
	@echo "    \"url\": \"${ADMIN_URL}\"," >> $@
	@echo "    \"allUsers\": \"${ADMIN_PORT_ALL_USERS}\"," >> $@
	@echo "    \"grantPrivilege\": \"local\"" >> $@
	@echo '} } }' >> $@

SERVICE_FILES += $(STAGING_DIR)/$(DSM_UI_DIR)/config
endif
endif

service_target: $(PRE_SERVICE_TARGET) $(SERVICE_FILES)

post_service_target: $(SERVICE_TARGET)

service: $(POST_SERVICE_TARGET)
