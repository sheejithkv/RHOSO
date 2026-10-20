# 10. GLANCE IMAGE ADMINISTRATION

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Images require verified source, image license, checksum and architecture/boot compatibility. Do not use an arbitrary URL as a trusted test image.

# [OS][RO] List images and visibility
openstack image list --long

# [OS][RO] Inspect image formats and checksum fields
openstack image show "${IMAGE}" -f yaml

# [OS][RO] Inspect image sharing membership
openstack image member list "${IMAGE}"

# [OS][RO] Inspect image import feature options
openstack image import --help

# [OS][RO] Inspect image API capabilities
openstack image create --help

# [OCP][RO] Verify downloaded local image SHA256 before upload
sha256sum "${IMAGE_FILE}"

# [OS][CHANGE] Upload verified local qcow2 image from OpenStackClient filesystem
openstack image create --disk-format qcow2 --container-format bare --file "${IMAGE_FILE}" --private "${IMAGE_NAME}"

# [OS][CHANGE] Set image property as approved
openstack image set --property "${PROPERTY_KEY}=${PROPERTY_VALUE}" "${IMAGE}"

# [OS][CHANGE] Share image with target project (image must use shared visibility)
openstack image set --shared "${IMAGE}"

# [OS][CHANGE] Add image share member for project
openstack image add project "${IMAGE}" "${PROJECT_ID}"

# [OS][CHANGE] Accept shared image from receiving project
openstack image set --accept "${IMAGE}"

# [OS][CHANGE] Download image only if policy permits local data copy
openstack image save --file "${DOWNLOAD_PATH}" "${IMAGE}"

# [OS][DELETE] Delete explicitly approved test image (destructive)
openstack image delete "${IMAGE}"
```