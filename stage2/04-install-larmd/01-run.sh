#!/bin/bash -e
# Create startup script

echo "#!/bin/sh -e
# Start larmd, create folder in ram-disk for status
mkdir /run/larmd
chown 1000:1000 /run/larmd
/home/${FIRST_USER_NAME}/bin/larm/larmd
exit 0" >> "${ROOTFS_DIR}"/etc/rc.local
chmod +x "${ROOTFS_DIR}"/etc/rc.local

# Copy scripts into image

mkdir -p "${ROOTFS_DIR}"/home/"${FIRST_USER_NAME}"/bin
cp -r "${BASE_DIR}"/larm "${ROOTFS_DIR}"/home/"${FIRST_USER_NAME}"/bin
chown -R 1000:1000 "${ROOTFS_DIR}"/home/"${FIRST_USER_NAME}"/bin
chmod +x "${ROOTFS_DIR}"/home/"${FIRST_USER_NAME}"/bin/larm/larmd
cp "${BASE_DIR}"/larm/90-larm-cdc.rules "${ROOTFS_DIR}"/etc/udev/rules.d
chown -R 1000:1000 "${ROOTFS_DIR}"/etc/udev/rules.d/90-larm-cdc.rules
cp "${BASE_DIR}"/larm/etc-rsyslog.d-larmd.conf "${ROOTFS_DIR}"/etc/rsyslog.d
chown -R 1000:1000 "${ROOTFS_DIR}"/etc/rsyslog.d/etc-rsyslog.d-larmd.conf
