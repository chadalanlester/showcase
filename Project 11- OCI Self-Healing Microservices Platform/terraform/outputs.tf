output "vcn_id"            { value = oci_core_vcn.main.id }
output "public_subnet_id"  { value = oci_core_subnet.public_subnet.id }
output "private_subnet_id" { value = oci_core_subnet.private_subnet.id }
output "oke_cluster_id"    { value = oci_containerengine_cluster.oke.id }
output "oke_node_pool_id"  { value = oci_containerengine_node_pool.pool.id }
output "artifact_bucket"   { value = oci_objectstorage_bucket.artifacts.name }
output "object_namespace"  { value = data.oci_objectstorage_namespace.ns.namespace }
output "atp_ocid"          { value = oci_database_autonomous_database.atp.id }
output "functions_dynamic_group_ocid" { value = oci_identity_dynamic_group.funcs.id }

output "kubeconfig_command" {
  value = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.oke.id} --file $HOME/.kube/oke-proj11 --region ${var.region} --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT"
}

output "atp_conn_strings_note" {
  value = "Download wallet in console later; ATP (Always Free) PROJ11DB created."
}
