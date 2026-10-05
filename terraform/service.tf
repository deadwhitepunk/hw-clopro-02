resource "yandex_iam_service_account" "ig_sa" {
  name      = "terraform"
  folder_id = var.folder_id
}