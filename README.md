# terraform-kubernetes-nodes
kubernetesのクラスタ用のKVMのVMを作成するterraformプロジェクト

## 使い方

`var.tfvars`に登録したいVM情報を追加

以下のコマンドで作成

```bash
$ terraform apply -var-file=var.tfvars
```

削除は以下のコマンド

```bash
$ terraform destroy -var-file=var.tfvars
```
