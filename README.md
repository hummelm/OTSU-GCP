# OTSU-GCP
in Google Cloud Console, execute:
```bash
git clone https://github.com/hummelm/OTSU-GCP.git
cd OTSU-GCP
terraform init
terraform plan
terraform apply
```

Wait for the cloud deployment to be ready:
```bash
watch -n 1 curl http://<LOADBALANCER_IP>
```

When finished, don't forget to release unused resources:
```bash
terraform destroy
```
