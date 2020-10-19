#self Service restore

	# tee restore.yaml >/dev/null <<EOF
	apiVersion: “powerprotect.dell.com/v1beta1”
	kind: RestoreJob
	metadata:
	  name: selfservice
	  namespace: powerprotect
	spec:
	  recoverType: RestoreToOriginal
	  backupJobName: backup_job_name
	namespaces:
	   - Name: namespace-name
	persistentVolumeClaims:
	   -“*”
	   
	EOF

	# kubectl apply -f restore.yaml -n powerprotect 
