%{ if enable_bootstrap_user_data ~}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========20221208145300=="

--==========20221208145300==
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment

#!/bin/bash
set -ex

%{ endif ~}
%{ if length(pre_bootstrap_user_data) > 0 ~}
# User-supplied pre userdata
${pre_bootstrap_user_data ~}
%{ endif ~}
%{ if format_mount_nvme_disk ~}
echo "Format and Mount NVMe Disks if available"
IDX=1
DEVICES=$(lsblk -o NAME,TYPE -dsn | awk '/disk/ {print $1}')

for DEV in $DEVICES
do
  mkfs.xfs /dev/$${DEV}
  mkdir -p /local$${IDX}

  echo /dev/$${DEV} /local$${IDX} xfs defaults,noatime 1 2 >> /etc/fstab

  IDX=$(($${IDX} + 1))
done
mount -a
%{ endif ~}
%{ if length(cluster_service_ipv4_cidr) > 0 ~}
export SERVICE_IPV4_CIDR=${cluster_service_ipv4_cidr}
%{ endif ~}
%{ if enable_bootstrap_user_data ~}
B64_CLUSTER_CA=${cluster_auth_base64}
API_SERVER_URL=${cluster_endpoint}
/etc/eks/bootstrap.sh ${cluster_name} --kubelet-extra-args "${kubelet_extra_args}" ${bootstrap_extra_args}
%{ if length(post_bootstrap_user_data) > 0 ~}
# User-supplied post userdata
${post_bootstrap_user_data ~}
%{ endif ~}

--==========20221208145300==--
%{ endif ~}
