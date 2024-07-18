%{ if enable_bootstrap_user_data ~}
${pre_bootstrap_user_data ~}
[settings.kubernetes]
"api-server" = "${cluster_endpoint}"
"cluster-certificate" = "${cluster_auth_base64}"
"cluster-name" = "${cluster_name}"
${post_bootstrap_user_data ~}
%{ endif ~}
