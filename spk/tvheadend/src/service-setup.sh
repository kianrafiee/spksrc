
# Package specific behaviors
# Sourced script by generic installer and start-stop-status scripts

# Delete syno group $GROUP if empty
remove_legacy_sc_user ()
{
    if [ -n "sc-${USER}" ]; then
        # Check if legacy user exists
        if synouser --get "sc-${USER}" &> /dev/null; then
            echo "Removing legacy user sc-${USER}" >> ${INST_LOG}
            synouser --del "sc-${USER}" >> ${INST_LOG} 2>&1
            synouser --rebuild all
        fi
    fi
}

# Delete syno group sc-$GROUP if empty
syno_sc_group_remove ()
{
    # Check if syno group is empty
    if ! synogroup --get "sc-${GROUP}" | grep -q "0:"; then
        # Remove syno group
        synogroup --del "sc-${GROUP}" >> ${INST_LOG}
    fi
}

service_preinst ()
{
    # On DSM 6 or higher, remove sc-user because part of "users" group
    if [ $SYNOPKG_DSM_VERSION_MAJOR -ge 6 ]; then
        remove_legacy_sc_user
    fi
    exit 0
}

service_postinst ()
{
    # Encrypt password
    wizard_password=`echo -n "TVHeadend-Hide-${wizard_password:=admin}" | openssl enc -a`

    # Edit the configuration according to the wizard
    sed -i -e "s/@username@/${wizard_username:=admin}/g" ${INSTALL_DIR}/var/accesscontrol/d80ccc09630261ffdcae1497a690acc8

    sed -i -e "s/@username@/${wizard_username:=admin}/g" ${INSTALL_DIR}/var/passwd/a927e30a755504f9784f23a4efac5109
    sed -i -e "s/@password@/${wizard_password}/g" ${INSTALL_DIR}/var/passwd/a927e30a755504f9784f23a4efac5109


    echo "Just installed" >> $INST_LOG
}

service_postuninst ()
{
    if [ "${SYNOPKG_PKG_STATUS}" == "UNINSTALL" ]; then
        # Remove syno sc-group if empty
        if ! [ synogroup --get "sc-$GROUP" | grep -q "0:\[" > /dev/null ]; then
            echo "Removing group sc-$GROUP" >> ${INST_LOG}
            synogroup --del "sc-$GROUP" >> ${INST_LOG} 2>&1
            synogroup --rebuild all
        fi
    fi
    # On DSM 6 or higher, remove legacy sc-user if still exists
    if [ $SYNOPKG_DSM_VERSION_MAJOR -ge 6 ]; then
        remove_legacy_sc_user
    fi
}

service_postupgrade ()
{
    # On DSM 6 or higher, remove legacy sc-user if still exists
    if [ $SYNOPKG_DSM_VERSION_MAJOR -ge 6 ]; then
        remove_sc_legacy_user
    fi
}
