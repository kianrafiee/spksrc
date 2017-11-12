
# Package specific behaviors
# Sourced script by generic installer and start-stop-status scripts

service_postinst ()
{
    echo "Just installed" >> $INST_LOG
}

service_prestart ()
{
    echo "Before start" >> $LOG_FILE
}

service_poststop ()
{
    echo "After stop" >> $LOG_FILE
}
