# OTSU-GCP
in Google Cloud Console, execute:
```bash
git clone https://github.com/hummelm/OTSU-GCP.git
cd OTSU-GCP
terraform init
terraform plan
terraform apply
```

wait for the systel to be fully ready:
```bash
watch -n 1 curl http://<LOADBALANCER_IP>
```

When finished, don't forget to release unused resources:
```bash
terraform destroy
```
